//
//  ReminderReconciler.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/28.
//

import OSLog

struct ReminderReconciler: Sendable {
    private let scheduler: NotificationScheduling

    init(scheduler: NotificationScheduling) {
        self.scheduler = scheduler
    }

    @discardableResult
    func reconcile(_ planned: [PlannedReminder]) async -> [String] {
        let desired = Set(planned.map(\.reminder.identifier))
        let stale = await scheduler.pendingIdentifiers().subtracting(desired)

        if !stale.isEmpty {
            await scheduler.removePending(identifiers: Array(stale))
        }

        for planned in planned {
            if Task.isCancelled {
                break
            }

            await add(planned.reminder)
        }

        return desired.sorted()
    }

    private func add(_ reminder: ScheduledReminder) async {
        do {
            try await scheduler.add(reminder)
        } catch {
            Logger(category: .data).error(
                "Reminder scheduling failed \(reminder.identifier, privacy: .public): \(error.localizedDescription, privacy: .public)"
            )
        }
    }
}
