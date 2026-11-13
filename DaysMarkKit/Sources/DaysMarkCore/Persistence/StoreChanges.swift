//
//  StoreChanges.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreData
import Foundation
import SwiftData

@MainActor
public struct StoreChanges {
    private let notificationCenter: NotificationCenter

    public init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    public func stream() -> AsyncStream<Void> {
        let center = notificationCenter

        return AsyncStream { continuation in
            let task = Task {
                await withDiscardingTaskGroup { group in
                    group.addTask {
                        for await _ in center.notifications(named: ModelContext.didSave) {
                            continuation.yield()
                        }
                    }

                    group.addTask {
                        let imports = center.notifications(
                            named: NSPersistentCloudKitContainer.eventChangedNotification
                        )

                        for await notification in imports
                        where notification.isFinishedCloudKitImport {
                            continuation.yield()
                        }
                    }
                }
            }

            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

extension Notification {
    var isFinishedCloudKitImport: Bool {
        let event =
            userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
            as? NSPersistentCloudKitContainer.Event

        return event.map { $0.type == .import && $0.endDate != nil && $0.succeeded } ?? false
    }
}
