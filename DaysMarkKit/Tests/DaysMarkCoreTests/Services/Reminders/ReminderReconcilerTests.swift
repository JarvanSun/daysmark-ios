//
//  ReminderReconcilerTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct ReminderReconcilerTests {
    private let berlin = TimeZone(identifier: "Europe/Berlin")!
    @Test
    func resubmitsWhenContentChangesUnderTheSameIdentifier() async throws {
        let rule = ReminderRule(daysBefore: 0, hour: 9)
        let event = event(day: 10)
        event.reminders = [rule]
        let identifier = try #require(
            ReminderPlanner().ordinaryReminders(
                for: event,
                now: try now(),
                userTimeZone: berlin
            ).first?.reminder.identifier
        )
        let center = NotificationSchedulerSpy(pending: [identifier])

        rule.hour = 18

        await ReminderReconciler(scheduler: center).reconcile(try planned([event]))

        #expect(center.added.count == 1)
        #expect(center.added.first?.dateComponents.hour == 18)

        #expect(center.removed.isEmpty)
    }

    @Test
    func keepsRemindersThatAreStillWanted() async throws {
        let event = event(day: 10)
        let existing = try #require(
            ReminderPlanner().ordinaryReminders(for: event, now: try now(), userTimeZone: berlin)
                .first
        )
        let center = NotificationSchedulerSpy(pending: [existing.reminder.identifier])

        await ReminderReconciler(scheduler: center).reconcile(try planned([event]))

        #expect(center.removed.isEmpty)
    }

    @Test
    func removesRemindersThatAreNoLongerWanted() async throws {
        let ghost = "\(UUID().uuidString).\(UUID().uuidString)"
        let center = NotificationSchedulerSpy(pending: [ghost])

        await ReminderReconciler(scheduler: center).reconcile(try planned([]))

        #expect(center.removed == [ghost])
    }

    @Test
    func addsNewlyDesiredReminders() async throws {
        let center = NotificationSchedulerSpy()

        await ReminderReconciler(scheduler: center).reconcile(try planned([event(day: 10)]))

        #expect(center.added.count == 1)
    }

    @Test
    func syncsOnlyTheDifference() async throws {
        let keep = event(day: 10, title: "keep")
        let keepID = try #require(
            ReminderPlanner().ordinaryReminders(for: keep, now: try now(), userTimeZone: berlin)
                .first
        ).reminder.identifier
        let ghost = "\(UUID().uuidString).\(UUID().uuidString)"
        let center = NotificationSchedulerSpy(pending: [keepID, ghost])

        await ReminderReconciler(scheduler: center).reconcile(try planned([keep]))

        #expect(center.removed == [ghost])

        #expect(center.added.map(\.identifier) == [keepID])
    }

    @Test
    func clearsEverythingWhenThereAreNoEvents() async throws {
        let center = NotificationSchedulerSpy(pending: ["a.b", "c.d"])

        await ReminderReconciler(scheduler: center).reconcile(try planned([]))

        #expect(Set(center.removed) == ["a.b", "c.d"])
    }

    @Test
    func oneFailureDoesNotStopTheRest() async throws {
        let center = NotificationSchedulerSpy(failure: MockError())

        let result = await ReminderReconciler(scheduler: center).reconcile(
            try planned([event(day: 10)])
        )

        #expect(result.count == 1)
    }

    @Test
    func cancellationStopsSubmitting() async throws {
        let center = NotificationSchedulerSpy()
        let events = (1...20).map { event(day: 10, title: "e\($0)", reminderCount: 3) }
        let reconciler = ReminderReconciler(scheduler: center)
        let planned = try planned(events)

        let task = Task { @MainActor in
            await reconciler.reconcile(planned)
        }
        task.cancel()
        _ = await task.value

        #expect(center.added.count < ReminderPlanner().pendingRequestLimit)
    }
}

private extension ReminderReconcilerTests {
    func date(_ y: Int, _ m: Int, _ d: Int, hour: Int = 12) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = berlin
        return try #require(
            calendar.date(from: DateComponents(year: y, month: m, day: d, hour: hour))
        )
    }

    func event(
        day: Int,
        month: Int = 9,
        title: String = "e",
        reminderCount: Int = 1
    ) -> CountdownEvent {
        let event = CountdownEvent.mock(
            title: title,
            year: 2026,
            month: month,
            day: day,
            timeZone: berlin
        )
        event.reminders = (0..<reminderCount).map { ReminderRule(daysBefore: $0, hour: 9) }
        return event
    }

    func now() throws -> Date { try date(2026, 8, 1) }

    func planned(_ events: [CountdownEvent]) throws -> [PlannedReminder] {
        ReminderPlanner().plan(
            for: events,
            now: try now(),
            userTimeZone: berlin,
            focusedEventID: nil
        )
    }
}
