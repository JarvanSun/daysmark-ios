//
//  BackgroundRefreshTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/07/28.
//

import DaysMarkCore
import Foundation
import SwiftData
import Testing

@testable import DaysMark

struct BackgroundRefreshTests {
    @Test func scheduleNextThenSubmitsTheShippedTaskSixHoursAhead() {
        // Given
        let scheduler = BackgroundTaskSchedulerSpy()
        let refresh = makeRefresh(scheduler: scheduler)

        // When
        refresh.scheduleNext()

        // Then
        #expect(
            scheduler.submissions == [
                BackgroundTaskSchedulerSpy.Submission(
                    identifier: "com.example.daysmark.reminderRefresh",
                    earliestBeginDate: Date.mockNow.addingTimeInterval(6 * 60 * 60)
                )
            ]
        )
    }

    @Test func scheduleNextThenNamesATaskTheInfoPlistPermits() throws {
        // Given
        let scheduler = BackgroundTaskSchedulerSpy()
        let permitted = try #require(
            Bundle.main.object(forInfoDictionaryKey: "BGTaskSchedulerPermittedIdentifiers")
                as? [String]
        )

        // When
        makeRefresh(scheduler: scheduler).scheduleNext()

        // Then
        #expect(scheduler.submissions.map(\.identifier) == permitted)
    }

    @Test func scheduleNextWhenSubmittingFailsThenCarriesOn() {
        // Given
        let scheduler = BackgroundTaskSchedulerSpy(failure: MockError())

        // When
        makeRefresh(scheduler: scheduler).scheduleNext()

        // Then
        #expect(scheduler.submissions.isEmpty)
    }

    @Test func refreshThenReconcilesRemindersAndReloadsWidgets() async {
        // Given
        let notifications = NotificationSchedulerSpy()
        let widgets = WidgetReloaderSpy()
        let refresh = makeRefresh(notifications: notifications, widgets: widgets)

        // When
        await refresh.refresh()

        // Then
        #expect(notifications.passes == 1)
        #expect(widgets.reloadCount == 1)
    }

    @Test func refreshWhenCancelledThenDoesNotReloadWidgets() async {
        // Given
        let widgets = WidgetReloaderSpy()
        let refresh = makeRefresh(widgets: widgets)

        // When
        let work = Task { await refresh.refresh() }
        work.cancel()
        await work.value

        // Then
        #expect(widgets.reloadCount == 0)
    }

    @Test func infoPlistThenDeclaresTheFetchBackgroundMode() throws {
        // Given / When
        let modes = try #require(
            Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String]
        )

        // Then
        #expect(modes.contains("fetch"))
    }

    private func makeRefresh(
        notifications: NotificationSchedulerSpy = NotificationSchedulerSpy(),
        widgets: WidgetReloaderSpy = WidgetReloaderSpy(),
        scheduler: BackgroundTaskSchedulerSpy = BackgroundTaskSchedulerSpy()
    ) -> BackgroundRefresh {
        let container = try! ModelContainer.mockInMemory()

        return BackgroundRefresh(
            reminders: ReminderService(
                container: container,
                scheduler: notifications,
                authorizer: NotificationAuthorizerStub(),
                now: { .mockNow },
                timeZone: { .gmt }
            ),
            widgets: widgets,
            scheduler: scheduler,
            now: { .mockNow }
        )
    }
}
