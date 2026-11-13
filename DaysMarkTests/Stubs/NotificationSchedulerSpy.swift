//
//  NotificationSchedulerSpy.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Synchronization

final class NotificationSchedulerSpy: NotificationScheduling {
    var passes: Int { recorded.withLock(\.self) }

    private let recorded = Mutex(0)

    func registerCategories() async {}

    func pendingIdentifiers() async -> Set<String> {
        recorded.withLock { $0 += 1 }
        return []
    }

    func add(_ reminder: ScheduledReminder) async throws {}

    func removePending(identifiers: [String]) async {}
}
