//
//  StoreImportObserver.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/05.
//

import Combine
import CoreData
import Foundation

@MainActor
public final class StoreImportObserver {
    private let onImport: @MainActor () -> Void

    private var subscriptions = Set<AnyCancellable>()
    private var pending: Task<Void, Never>?

    public init(notificationCenter: NotificationCenter, onImport: @escaping @MainActor () -> Void) {
        self.onImport = onImport

        notificationCenter.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .receive(on: RunLoop.main)
            .filter(\.isFinishedCloudKitImport)
            .sink { [weak self] _ in self?.noteImport() }
            .store(in: &subscriptions)
    }

    func noteImport() {
        guard pending == nil else { return }

        pending = Task { [weak self] in
            await Task.yield()

            guard let self else { return }

            pending = nil
            onImport()
        }
    }
}
