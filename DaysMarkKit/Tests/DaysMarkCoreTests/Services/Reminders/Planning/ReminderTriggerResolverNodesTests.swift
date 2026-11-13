//
//  ReminderTriggerResolverNodesTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct ReminderTriggerResolverNodesTests {
    private let planner = ReminderPlanner()
    private let berlin = TimeZone(identifier: "Europe/Berlin")!
    @Test
    func beforeNodeUsesTheNextOccurrenceStart() throws {
        let event = makeEvent(year: 2020, month: 9, day: 10, repeatRule: .yearly)
        addNode(.beforeDays, value: 7, to: event, hour: 9)
        let now = try #require(date(2026, 9, 5, hour: 12))

        let planned = try #require(
            planner.specialNodeReminders(
                for: event,
                now: now,
                userTimeZone: berlin
            ).first
        )
        #expect(planned.reminder.dateComponents.year == 2027)
        #expect(planned.reminder.dateComponents.month == 9)
        #expect(planned.reminder.dateComponents.day == 3)
    }

    @Test
    func beforeNodeSkipsEnoughDailyOccurrences() throws {
        let event = makeEvent(
            year: 2020,
            month: 1,
            day: 1,
            repeatRule: .custom
        )
        event.repeatInterval = 1
        event.repeatUnit = .day
        addNode(.beforeDays, value: 7, to: event, hour: 9)
        let now = try #require(date(2026, 9, 1, hour: 12))

        let planned = try #require(
            planner.specialNodeReminders(
                for: event,
                now: now,
                userTimeZone: berlin
            ).first
        )

        #expect(planned.reminder.dateComponents.year == 2026)
        #expect(planned.reminder.dateComponents.month == 9)
        #expect(planned.reminder.dateComponents.day == 2)
    }

    @Test
    func elapsedNodeUsesOriginalStart() throws {
        let event = makeEvent(year: 2026, month: 1, day: 1, repeatRule: .yearly)
        addNode(.elapsedDays, value: 100, to: event, hour: 9)
        let now = try #require(date(2026, 1, 2))

        let planned = try #require(
            planner.specialNodeReminders(
                for: event,
                now: now,
                userTimeZone: berlin
            ).first
        )
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = berlin
        let original = try #require(date(2026, 1, 1, hour: 9))
        #expect(calendar.dateComponents([.day], from: original, to: planned.fireDate).day == 100)
    }

    @Test
    func anniversaryUsesOriginalStart() throws {
        let event = makeEvent(year: 2020, month: 6, day: 15, repeatRule: .yearly)
        addNode(.anniversaryYears, value: 10, to: event, hour: 8)
        let now = try #require(date(2029, 1, 1))
        let planned = try #require(
            planner.specialNodeReminders(
                for: event,
                now: now,
                userTimeZone: berlin
            ).first
        )
        #expect(planned.reminder.dateComponents.year == 2030)
        #expect(planned.reminder.dateComponents.month == 6)
        #expect(planned.reminder.dateComponents.day == 15)
    }

    @Test
    func chineseLeapMonthAnniversaryKeepsLeapIdentity() throws {
        let utc = try #require(TimeZone(secondsFromGMT: 0))
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = utc
        let anchor = try #require(
            gregorian.date(from: DateComponents(year: 2023, month: 3, day: 22))
        )
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = utc
        let parts = chinese.dateComponents([.era, .year, .month, .day], from: anchor)
        let event = CountdownEvent.mock(
            title: "Leap month anniversary",
            year: try #require(parts.year),
            month: try #require(parts.month),
            day: try #require(parts.day),
            timeZone: utc,
            calendarSystem: .chinese
        )
        event.targetEra = parts.era
        event.targetIsLeapMonth = true
        addNode(.anniversaryYears, value: 1, to: event, hour: 9)

        let planned = planner.specialNodeReminders(
            for: event,
            now: try #require(
                gregorian.date(from: DateComponents(year: 2023, month: 1, day: 1))
            ),
            userTimeZone: utc
        )

        #expect(planned.isEmpty)
    }

    @Test
    func floatingSpecialNodeKeepsFloatingComponents() throws {
        let event = makeEvent(year: 2030, month: 1, day: 1)
        addNode(.beforeDays, value: 7, to: event, hour: 9)
        let now = try #require(date(2029, 12, 1))
        let planned = try #require(
            planner.specialNodeReminders(
                for: event,
                now: now,
                userTimeZone: berlin
            ).first
        )

        #expect(planned.reminder.dateComponents.timeZone == nil)
    }

    @Test
    func ordinaryAndSpecialRemainIndependent() throws {
        let event = makeEvent(year: 2026, month: 8, day: 20)
        let rule = ReminderRule(daysBefore: 7, hour: 9)
        rule.event = event
        event.reminders = [rule]
        addNode(.beforeDays, value: 7, to: event, hour: 9)
        let now = try #require(date(2026, 8, 1))

        let ordinary = planner.ordinaryReminders(
            for: event,
            now: now,
            userTimeZone: berlin
        )
        let special = planner.specialNodeReminders(
            for: event,
            now: now,
            userTimeZone: berlin
        )
        #expect(ordinary.count == 1)
        #expect(special.count == 1)
        #expect(ordinary.first?.fireDate == special.first?.fireDate)
        #expect(ordinary.first?.reminder.identifier != special.first?.reminder.identifier)
    }

    @Test
    func missingNodeTimeSchedulesNothing() {
        let event = makeEvent(year: 2030, month: 1, day: 1)
        let node = SpecialReminderNode(eventID: event.id, kind: .beforeDays, value: 7)
        node.event = event
        event.specialReminderNodes = [node]
        #expect(
            planner.specialNodeReminders(for: event, now: .mockNow, userTimeZone: berlin).isEmpty
        )
    }
}

private extension ReminderTriggerResolverNodesTests {
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

    func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = berlin
        return calendar.date(
            from: DateComponents(year: year, month: month, day: day, hour: hour)
        )
    }
}
