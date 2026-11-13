//
//  BackgroundRefresh.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import BackgroundTasks
import DaysMarkCore
import OSLog

struct BackgroundRefresh {
    private let reminders: ReminderService
    private let widgets: WidgetReloading
    private let scheduler: BackgroundTaskScheduling
    private let now: () -> Date

    init(
        reminders: ReminderService,
        widgets: WidgetReloading,
        scheduler: BackgroundTaskScheduling,
        now: @escaping () -> Date
    ) {
        self.reminders = reminders
        self.widgets = widgets
        self.scheduler = scheduler
        self.now = now
    }

    func register() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: TaskIdentifier.reminderRefresh.rawValue,
            using: .main
        ) { task in
            refresh(during: task)
        }
    }

    private func refresh(during task: BGTask) {
        let work = Task {
            await refresh()
            scheduleNext()
            task.setTaskCompleted(success: !Task.isCancelled)
        }

        task.expirationHandler = { work.cancel() }
    }

    func scheduleNext() {
        do {
            try scheduler.submit(
                identifier: TaskIdentifier.reminderRefresh.rawValue,
                earliestBeginDate: now().addingTimeInterval(minimumInterval)
            )
        } catch {
            Logger(category: .data).error(
                "Background refresh scheduling failed: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    private var minimumInterval: TimeInterval { 60 * 60 * 6 }

    func refresh() async {
        await reminders.reconcile()

        guard !Task.isCancelled else { return }

        widgets.reloadAll()
    }
}

extension BackgroundRefresh {
    private enum TaskIdentifier: String {
        case reminderRefresh = "com.example.daysmark.reminderRefresh"
    }
}
