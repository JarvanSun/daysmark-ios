//
//  ModelContainerBuilder.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/31.
//

import Foundation
import OSLog
import SwiftData

public struct ModelContainerBuilder: Sendable {
    private let role: StoreRole
    private let storage: StoreStorage

    public init(role: StoreRole, storage: StoreStorage) {
        self.role = role
        self.storage = storage
    }

    public var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: StoreIdentifier.appGroup.rawValue) ?? .standard
    }

    public func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: schema, configurations: [configuration])
    }

    public func makeLocalSourceContainer() -> ModelContainer? {
        makeLocalSourceContainer(opening: openLocalSourceContainer)
    }
}

// MARK: - Schema and store

extension ModelContainerBuilder {
    var schema: Schema {
        Schema(syncedModels)
    }

    var syncedModels: [any PersistentModel.Type] {
        [
            CountdownEvent.self,
            EventCategory.self,
            ReminderRule.self,
            SpecialReminderNode.self,
            EventRevision.self,
            PermanentDeletionMarker.self,
            FocusSelection.self,
            FocusSelectionRevision.self,
        ]
    }

    var localSourceSchema: Schema {
        Schema([LocalSourceReference.self, LocalSourceCleanupRequest.self])
    }

    var storeURL: URL? {
        let identifier = StoreIdentifier.appGroup.rawValue
        let group = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: identifier
        )

        guard let group else {
            Logger(category: .data).error(
                "App Group container unavailable \(identifier, privacy: .public); using default storage, unavailable to widgets"
            )
            return nil
        }

        return group.appending(path: StoreIdentifier.storeFile.rawValue)
    }

    func configuration(at url: URL) -> ModelConfiguration {
        ModelConfiguration(
            StoreIdentifier.configuration.rawValue,
            schema: schema,
            url: url,
            allowsSave: allowsSave,
            cloudKitDatabase: cloudKitDatabase
        )
    }

    func makeLocalSourceContainer(opening open: () throws -> ModelContainer) -> ModelContainer? {
        do {
            return try open()
        } catch {
            Logger(category: .data).error(
                "Local source store unavailable; imports disabled: \(error.localizedDescription, privacy: .public)"
            )
            return nil
        }
    }

    func openLocalSourceContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            StoreIdentifier.localSources.rawValue,
            schema: localSourceSchema,
            isStoredInMemoryOnly: storage == .inMemory,
            allowsSave: true,
            groupContainer: .none,
            cloudKitDatabase: .none
        )

        return try ModelContainer(for: localSourceSchema, configurations: [configuration])
    }
}

// MARK: - Private

private extension ModelContainerBuilder {
    var allowsSave: Bool {
        switch role {
        case .app: true
        case .widget: false
        }
    }

    var cloudKitDatabase: ModelConfiguration.CloudKitDatabase {
        switch role {
        case .app: .private(StoreIdentifier.cloudKitContainer.rawValue)
        case .widget: .none
        }
    }

    var configuration: ModelConfiguration {
        switch storage {
        case .inMemory: inMemoryConfiguration
        case .appGroup: storeURL.map(configuration(at:)) ?? defaultLocationConfiguration
        }
    }

    var inMemoryConfiguration: ModelConfiguration {
        ModelConfiguration(
            StoreIdentifier.inMemoryConfiguration.rawValue,
            schema: schema,
            isStoredInMemoryOnly: true,
            allowsSave: true,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
    }

    var defaultLocationConfiguration: ModelConfiguration {
        ModelConfiguration(
            StoreIdentifier.configuration.rawValue,
            schema: schema,
            allowsSave: allowsSave,
            groupContainer: .none,
            cloudKitDatabase: .none
        )
    }
}

// MARK: - Store values

enum StoreIdentifier: String {
    case appGroup = "group.com.example.daysmark"
    case cloudKitContainer = "iCloud.com.example.daysmark"
    case storeFile = "CountdownDays.store"
    case configuration = "CountdownDays"
    case inMemoryConfiguration = "CountdownDaysInMemory"
    case localSources = "CountdownDaysLocalSources"
}

public enum StoreRole: Sendable {
    case app
    case widget
}

public enum StoreStorage: Sendable {
    case appGroup
    case inMemory
}
