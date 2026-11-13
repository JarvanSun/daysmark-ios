//
//  SystemSurfaceRefresher.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

@MainActor
public protocol SystemSurfaceRefreshing {
    func refresh()
}

@MainActor
public final class SystemSurfaceRefresher: SystemSurfaceRefreshing {
    private(set) var inFlight: Task<Void, Never>?

    private let reminders: ReminderService
    private let widgets: WidgetReloading
    private let spotlight: SpotlightIndexer
    private let liveActivities: LiveActivityService
    private let now: () -> Date

    private var hasQueuedPass = false

    public init(
        reminders: ReminderService,
        widgets: WidgetReloading,
        spotlight: SpotlightIndexer,
        liveActivities: LiveActivityService,
        now: @escaping () -> Date
    ) {
        self.reminders = reminders
        self.widgets = widgets
        self.spotlight = spotlight
        self.liveActivities = liveActivities
        self.now = now
    }

    public func refresh() {
        guard !hasQueuedPass else { return }

        hasQueuedPass = true

        let previous = inFlight
        inFlight = Task {
            await previous?.value
            hasQueuedPass = false

            await runPass()
        }
    }

    private func runPass() async {
        await reminders.reconcile()
        widgets.reloadAll()
        await spotlight.reindex(at: now())
        await liveActivities.reconcile(at: now())
    }
}
