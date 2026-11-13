//
//  CloudKitSchemaInitializer.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/10/07.
//

#if DEBUG
import CoreData
import OSLog
import SwiftData

public struct CloudKitSchemaInitializer {
    private let arguments: [String]
    private let logger = Logger(subsystem: "com.example.daysmark", category: "CloudKitSchema")

    public init(arguments: [String]) {
        self.arguments = arguments
    }

    public func runIfRequested() {
        guard arguments.contains(launchArgument) else { return }

        guard let model = NSManagedObjectModel.makeManagedObjectModel(for: syncedModels) else {
            logger.error("CloudKit schema: could not build managed object model")
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appending(path: "cloudkit-schema-\(UUID().uuidString).store")
        let container = container(for: model, storedAt: url)

        upload(from: container)

        for store in container.persistentStoreCoordinator.persistentStores {
            try? container.persistentStoreCoordinator.remove(store)
        }

        try? FileManager.default.removeItem(at: url)
    }

    private var launchArgument: String { "-initializeCloudKitSchema" }

    private var syncedModels: [any PersistentModel.Type] {
        ModelContainerBuilder(role: .app, storage: .inMemory).syncedModels
    }

    private func container(
        for model: NSManagedObjectModel,
        storedAt url: URL
    ) -> NSPersistentCloudKitContainer {
        let description = NSPersistentStoreDescription(url: url)
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: StoreIdentifier.cloudKitContainer.rawValue
        )
        description.shouldAddStoreAsynchronously = false

        let container = NSPersistentCloudKitContainer(
            name: StoreIdentifier.configuration.rawValue,
            managedObjectModel: model
        )
        container.persistentStoreDescriptions = [description]

        return container
    }

    private func upload(from container: NSPersistentCloudKitContainer) {
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }

        do {
            if let loadError {
                throw loadError
            }

            try container.initializeCloudKitSchema()
            logger.notice("CloudKit schema: initialized")
        } catch {
            logger.error("CloudKit schema: failed \(error, privacy: .public)")
        }
    }
}
#endif
