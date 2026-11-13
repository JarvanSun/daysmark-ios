//
//  SystemSurfaceRefresherTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Synchronization
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct SystemSurfaceRefresherTests {
    @Test func refreshThenReconcilesRemindersBeforeReloadingWidgets() async {
        // Given
        let steps = Mutex<[String]>([])
        let scheduler = NotificationSchedulerSpy { steps.withLock { $0.append("reminders") } }
        let widgets = WidgetReloaderSpy { steps.withLock { $0.append("widgets") } }
        let refresher = makeRefresher(scheduler: scheduler, widgets: widgets)

        // When
        refresher.refresh()
        await refresher.inFlight?.value

        // Then
        #expect(steps.withLock(\.self) == ["reminders", "widgets"])
    }

    @Test func refreshWhenRequestedRepeatedlyBeforeThePassStartsThenRunsOnePass() async {
        // Given
        let scheduler = NotificationSchedulerSpy()
        let widgets = WidgetReloaderSpy()
        let refresher = makeRefresher(scheduler: scheduler, widgets: widgets)

        // When
        for _ in 0..<10 {
            refresher.refresh()
        }

        await refresher.inFlight?.value

        // Then
        #expect(scheduler.passes == 1)
        #expect(widgets.reloadCount == 1)
    }

    @Test func refreshWhenRequestedDuringAPassThenQueuesExactlyOneMore() async {
        // Given
        let (started, continuation) = AsyncStream.makeStream(of: Void.self)
        let scheduler = NotificationSchedulerSpy { continuation.yield() }
        let refresher = makeRefresher(scheduler: scheduler)

        // When
        refresher.refresh()

        for await _ in started {
            break
        }

        for _ in 0..<3 {
            refresher.refresh()
        }

        await refresher.inFlight?.value

        // Then
        #expect(scheduler.passes == 2)
        #expect(scheduler.mostConcurrentPasses == 1)
    }

    @Test func refreshWhenAPassCompletedThenRunsAnother() async {
        // Given
        let scheduler = NotificationSchedulerSpy()
        let refresher = makeRefresher(scheduler: scheduler)

        // When
        refresher.refresh()
        await refresher.inFlight?.value
        refresher.refresh()
        await refresher.inFlight?.value

        // Then
        #expect(scheduler.passes == 2)
    }

    private func makeRefresher(
        scheduler: NotificationSchedulerSpy = NotificationSchedulerSpy(),
        widgets: WidgetReloaderSpy = WidgetReloaderSpy()
    ) -> SystemSurfaceRefresher {
        let container = ModelContainer.mockInMemory()
        let defaults = UserDefaults(suiteName: "SystemSurfaceRefresherTests") ?? .standard

        return SystemSurfaceRefresher(
            reminders: ReminderService(
                container: container,
                scheduler: scheduler,
                authorizer: NotificationAuthorizerStub(permission: .authorized),
                now: { .mockNow },
                timeZone: { .mockUTC }
            ),
            widgets: widgets,
            spotlight: SpotlightIndexer(container: container, timeZone: { .mockUTC }),
            liveActivities: LiveActivityService(
                container: container,
                defaults: defaults,
                timeZone: { .mockUTC }
            ),
            now: { .mockNow }
        )
    }
}
