//
//  ReminderPlannerTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct ReminderPlannerTests {
    private let berlin = TimeZone(identifier: "Europe/Berlin")!
    private let tokyo = TimeZone(identifier: "Asia/Tokyo")!
    @Test
    func identifierCombinesEventAndRule() throws {
        let rule = ReminderRule(daysBefore: 0, hour: 9)
        let event = event(2026, 8, 20, tz: berlin, reminders: [rule])

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 8, 1, tz: berlin),
            userTimeZone: berlin
        )

        #expect(planned.count == 1)
        let prefix = "\(event.id.uuidString).\(rule.id.uuidString)."
        #expect(planned.first?.reminder.identifier.hasPrefix(prefix) == true)
    }

    @Test
    func identifierStillCarriesTheEventPrefix() throws {
        let event = event(
            2026,
            8,
            20,
            tz: berlin,
            reminders: [ReminderRule(daysBefore: 0, hour: 9)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 8, 1, tz: berlin),
            userTimeZone: berlin
        )

        let prefix = "\(event.id.uuidString)."
        #expect(planned.allSatisfy { $0.reminder.identifier.hasPrefix(prefix) })
    }

    @Test
    func springForwardGapIsSkipped() throws {

        let event = event(
            2027,
            3,
            28,
            tz: berlin,
            reminders: [ReminderRule(daysBefore: 0, hour: 2, minute: 30)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2027, 3, 1, tz: berlin),
            userTimeZone: berlin
        )
        #expect(planned.isEmpty)
    }

    @Test
    func ordinaryReminderSkipsTheSpringForwardGap() throws {
        let event = event(
            2027,
            3,
            28,
            tz: berlin,
            reminders: [ReminderRule(daysBefore: 0, hour: 2, minute: 30)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2027, 3, 1, tz: berlin),
            userTimeZone: berlin
        )

        #expect(planned.isEmpty)
    }

    @Test
    func allDayTriggerKeepsFloatingComponents() throws {
        let event = event(
            2026,
            8,
            20,
            tz: berlin,
            reminders: [ReminderRule(daysBefore: 0, hour: 9)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 8, 1, tz: tokyo),
            userTimeZone: tokyo
        )

        let components = try #require(planned.first?.reminder.dateComponents)
        #expect(components.timeZone == nil)
        #expect(components.hour == 9)
    }

    @Test
    func timedTriggerUsesTheSelectedTimeSemantics() throws {
        let floating = CountdownEvent.mock(
            title: "Local meeting",
            year: 2026,
            month: 8,
            day: 20,
            hour: 9,
            minute: 0,
            timeZone: berlin,
            timeSemantics: .floatingLocalTime
        )
        let floatingRule = ReminderRule(
            eventID: floating.id,
            kind: .exactTimeOffset,
            minutesBefore: 0
        )
        floatingRule.event = floating
        floating.reminders = [floatingRule]

        let fixed = CountdownEvent.mock(
            title: "Flight",
            year: 2026,
            month: 8,
            day: 20,
            hour: 9,
            minute: 0,
            timeZone: berlin,
            timeSemantics: .fixedInstant
        )
        let fixedRule = ReminderRule(
            eventID: fixed.id,
            kind: .exactTimeOffset,
            minutesBefore: 0
        )
        fixedRule.event = fixed
        fixed.reminders = [fixedRule]
        let now = try date(2026, 8, 1, tz: tokyo)

        let floatingComponents = try #require(
            ReminderPlanner().ordinaryReminders(
                for: floating,
                now: now,
                userTimeZone: tokyo
            ).first?.reminder.dateComponents
        )
        let fixedComponents = try #require(
            ReminderPlanner().ordinaryReminders(
                for: fixed,
                now: now,
                userTimeZone: tokyo
            ).first?.reminder.dateComponents
        )

        #expect(floatingComponents.timeZone == nil)
        #expect(fixedComponents.timeZone == berlin)
    }

    @Test
    func offsetsFireBeforeTheEvent() throws {
        let event = event(
            2026,
            8,
            20,
            tz: berlin,
            reminders: [ReminderRule(daysBefore: 7, hour: 8, minute: 30)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 8, 1, tz: berlin),
            userTimeZone: berlin
        )

        let components = try #require(planned.first?.reminder.dateComponents)
        #expect(components.month == 8)
        #expect(components.day == 13)
        #expect(components.hour == 8)
        #expect(components.minute == 30)
        #expect(planned.first?.reminder.body == "in 7 days")
    }

    @Test
    func schedulesEveryRule() throws {
        let event = event(
            2026,
            8,
            20,
            tz: berlin,
            reminders: [
                ReminderRule(daysBefore: 0), ReminderRule(daysBefore: 1),
                ReminderRule(daysBefore: 7),
            ]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 8, 1, tz: berlin),
            userTimeZone: berlin
        )

        #expect(planned.count == 3)
        #expect(Set(planned.map(\.reminder.identifier)).count == 3)
    }

    @Test
    func skipsTriggersInThePast() throws {
        let event = event(
            2026,
            8,
            20,
            tz: berlin,
            reminders: [ReminderRule(daysBefore: 7, hour: 9)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 8, 19, tz: berlin),
            userTimeZone: berlin
        )

        #expect(planned.isEmpty)
    }

    @Test
    func skipsOnlyThePastOnes() throws {
        let event = event(
            2026,
            8,
            20,
            tz: berlin,
            reminders: [ReminderRule(daysBefore: 7, hour: 9), ReminderRule(daysBefore: 0, hour: 9)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 8, 19, tz: berlin),
            userTimeZone: berlin
        )

        #expect(planned.count == 1)
        #expect(planned.first?.reminder.dateComponents.day == 20)
    }

    @Test
    func repeatingEventsScheduleFromTheNextOccurrence() throws {
        let event = event(
            2000,
            3,
            9,
            tz: berlin,
            rule: .yearly,
            reminders: [ReminderRule(daysBefore: 0, hour: 9)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 8, 20, tz: berlin),
            userTimeZone: berlin
        )

        let components = try #require(planned.first?.reminder.dateComponents)
        #expect(components.year == 2027)
        #expect(components.month == 3)
        #expect(components.day == 9)
    }

    @Test
    func missedOffsetForCurrentOccurrenceRollsForward() throws {
        let event = event(
            2020,
            9,
            10,
            tz: berlin,
            rule: .yearly,
            reminders: [ReminderRule(daysBefore: 7, hour: 9)]
        )

        let planned = ReminderPlanner().ordinaryReminders(
            for: event,
            now: try date(2026, 9, 5, tz: berlin),
            userTimeZone: berlin
        )

        let components = try #require(planned.first?.reminder.dateComponents)
        #expect(components.year == 2027)
        #expect(components.month == 9)
        #expect(components.day == 3)
    }

    @Test
    func noRulesPlansNothing() throws {
        let planned = ReminderPlanner().ordinaryReminders(
            for: event(2026, 8, 20, tz: berlin),
            now: try date(2026, 8, 1, tz: berlin),
            userTimeZone: berlin
        )

        #expect(planned.isEmpty)
    }

    @Test
    func invalidEventSchedulesNothing() throws {
        let broken = CountdownEvent.mock(
            title: "x",
            year: 2026,
            month: 13,
            day: 40,
            timeZone: berlin
        )
        broken.reminders = [ReminderRule(daysBefore: 0)]

        let planned = ReminderPlanner().ordinaryReminders(
            for: broken,
            now: try date(2026, 8, 1, tz: berlin),
            userTimeZone: berlin
        )

        #expect(planned.isEmpty)
    }

    @Test
    func truncatesToTheCap() throws {
        let events = (1...40).map {
            event(day: min($0, 30), month: 9 + $0 % 3, title: "e\($0)", reminderCount: 3)
        }

        let desired = ReminderPlanner().plan(
            for: events,
            now: try now(),
            userTimeZone: berlin,
            focusedEventID: nil
        )

        #expect(desired.count == ReminderPlanner().pendingRequestLimit)
    }

    @Test
    func keepsTheEarliestOnes() throws {
        let soon = event(day: 2, month: 9, title: "soon")
        let later = event(day: 20, month: 12, title: "later")
        let events = [later, soon]

        let desired = ReminderPlanner().plan(
            for: events,
            now: try now(),
            userTimeZone: berlin,
            focusedEventID: nil
        )

        #expect(desired.first?.reminder.title == "soon")
    }

    @Test
    func schedulesDistantRemindersWhenUnderTheCap() throws {
        let distant = event(day: 15, month: 12, title: "far away")

        let desired = ReminderPlanner().plan(
            for: [distant],
            now: try now(),
            userTimeZone: berlin,
            focusedEventID: nil
        )

        #expect(desired.count == 1)
    }

    @Test
    func sortsAcrossEventsByFireDate() throws {
        let a = event(day: 10, month: 9, title: "A", reminderCount: 2)
        let b = event(day: 9, month: 9, title: "B")

        let desired = ReminderPlanner().plan(
            for: [a, b],
            now: try now(),
            userTimeZone: berlin,
            focusedEventID: nil
        )

        let fireDates = desired.map(\.fireDate)
        #expect(fireDates == fireDates.sorted())
    }

    @Test
    func pastTriggersDoNotConsumeBudget() throws {
        let past = event(day: 1, month: 7, title: "past")

        let desired = ReminderPlanner().plan(
            for: [past],
            now: try now(),
            userTimeZone: berlin,
            focusedEventID: nil
        )

        #expect(desired.isEmpty)
    }

    @Test
    func reconciliationIsStableAcrossRuns() throws {
        let events = (1...30).map { event(day: 10, month: 9, title: "e\($0)", reminderCount: 3) }
        let reconciler = ReminderPlanner()

        let first = reconciler.plan(
            for: events,
            now: try now(),
            userTimeZone: berlin,
            focusedEventID: nil
        )
        let second = reconciler.plan(
            for: events,
            now: try now(),
            userTimeZone: berlin,
            focusedEventID: nil
        )

        #expect(first.map(\.reminder.identifier) == second.map(\.reminder.identifier))
    }

    @Test
    func capUsesTheSystemLimit() {
        #expect(ReminderPlanner().pendingRequestLimit == 64)
    }

    @Test
    func capacityPrioritizesTheFocusEvent() throws {
        let events = (0..<65).map { index in
            let event = makeEvent(year: 2030, month: 1, day: 1, title: "Event \(index)")
            let rule = ReminderRule(daysBefore: 0, hour: 9)
            rule.event = event
            event.reminders = [rule]
            return event
        }
        let focus = try #require(events.last)
        let desired = ReminderPlanner().plan(
            for: events,
            now: try date(2029, 12, 1, hour: 0),
            userTimeZone: berlin,
            focusedEventID: focus.id
        )
        #expect(desired.count == 64)
        #expect(desired.contains { $0.eventID == focus.id })
        #expect(desired.first?.eventID == focus.id)
    }

    @Test
    func capacityUsesKindBeforeIdentifier() throws {
        let event = makeEvent(year: 2030, month: 1, day: 1)
        event.reminders = (0..<64).map { _ in
            let rule = ReminderRule(eventID: event.id, daysBefore: 1, hour: 9)
            rule.event = event
            return rule
        }
        addNode(.beforeDays, value: 1, to: event, hour: 9)

        let desired = ReminderPlanner().plan(
            for: [event],
            now: try date(2029, 12, 1, hour: 0),
            userTimeZone: berlin,
            focusedEventID: nil
        )

        #expect(desired.count == 64)
        #expect(desired.allSatisfy { $0.kind == .ordinary })
        #expect(desired.allSatisfy { !$0.reminder.identifier.contains(".special.") })
    }
}

private extension ReminderPlannerTests {
    func date(_ y: Int, _ m: Int, _ d: Int, hour: Int = 12, tz: TimeZone) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tz
        return try #require(
            calendar.date(from: DateComponents(year: y, month: m, day: d, hour: hour))
        )
    }

    func event(
        _ y: Int,
        _ m: Int,
        _ d: Int,
        title: String = "Mum's birthday",
        tz: TimeZone,
        rule: RepeatRule = .never,
        reminders: [ReminderRule] = []
    ) -> CountdownEvent {
        let event = CountdownEvent.mock(
            title: title,
            year: y,
            month: m,
            day: d,
            timeZone: tz,
            repeatRule: rule
        )
        event.reminders = reminders
        return event
    }

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

    func makeEvent(
        year: Int,
        month: Int,
        day: Int,
        title: String = "Event",
        repeatRule: RepeatRule = .never
    ) -> CountdownEvent {
        CountdownEvent.mock(
            title: title,
            year: year,
            month: month,
            day: day,
            timeZone: berlin,
            repeatRule: repeatRule
        )
    }

    func addNode(
        _ kind: SpecialReminderNodeKind,
        value: Int,
        to event: CountdownEvent,
        hour: Int,
        minute: Int = 0
    ) {
        let node = SpecialReminderNode(eventID: event.id, kind: kind, value: value)
        node.event = event
        event.specialReminderNodes = [node]
        event.specialNodeNotificationHour = hour
        event.specialNodeNotificationMinute = minute
    }
}
