//
//  LiveActivityPlannerTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/04.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct LiveActivityPlannerTests {
    private let planner = LiveActivityPlanner()
    private let now = Date(timeIntervalSince1970: 2_000_000_000)

    @Test func pointEventAppearsWithinOneHourAndLingersForFifteenMinutes() {
        let start = now.addingTimeInterval(3_600)
        let occurrence = occurrence(start: start)

        #expect(
            planner.plan(occurrence: occurrence, semantics: .fixedInstant, now: now)?.target
                == .point
        )
        #expect(
            planner.plan(occurrence: occurrence, semantics: .fixedInstant, now: now)?.isTerminal
                == false
        )
        #expect(
            planner.plan(
                occurrence: occurrence,
                semantics: .fixedInstant,
                now: start.addingTimeInterval(900)
            )?.isTerminal == true
        )
        #expect(
            planner.plan(
                occurrence: occurrence,
                semantics: .fixedInstant,
                now: start.addingTimeInterval(901)
            ) == nil
        )
    }

    @Test func pointEventOutsideEligibilityWindowIsExcluded() {
        let occurrence = occurrence(start: now.addingTimeInterval(3_601))
        #expect(planner.plan(occurrence: occurrence, semantics: .fixedInstant, now: now) == nil)
    }

    @Test func rangeSwitchesFromStartToEndAndStopsAtEnd() {
        let start = now.addingTimeInterval(1_800)
        let end = now.addingTimeInterval(7_200)
        let occurrence = occurrence(start: start, end: end)

        let beforeStart = planner.plan(occurrence: occurrence, semantics: .fixedInstant, now: now)
        #expect(beforeStart?.target == .start)
        #expect(beforeStart?.targetDate == start)

        let during = planner.plan(
            occurrence: occurrence,
            semantics: .fixedInstant,
            now: start.addingTimeInterval(1)
        )
        #expect(during?.target == .end)
        #expect(during?.targetDate == end)
        #expect(planner.plan(occurrence: occurrence, semantics: .fixedInstant, now: end) == nil)
    }

    @Test func allDayEventsNeverProduceLiveActivityPlans() {
        let occurrence = occurrence(start: now.addingTimeInterval(60))
        #expect(planner.plan(occurrence: occurrence, semantics: .floatingAllDay, now: now) == nil)
    }

    private func occurrence(start: Date, end: Date? = nil) -> EventOccurrence {
        EventOccurrence(
            start: specification(for: start),
            end: end.map(specification),
            startDate: start,
            endDate: end
        )
    }

    private func specification(for date: Date) -> EventDateSpecification {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return EventDateSpecification(
            calendarSystem: .gregorian,
            year: components.year!,
            month: components.month!,
            day: components.day!,
            hour: components.hour,
            minute: components.minute
        )
    }
}
