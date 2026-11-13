//
//  EventDetailUnitTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import EventsFeature

struct EventDetailUnitTests {
    @Test(arguments: [
        (EventDetailUnit.days, EventDetailUnit.weeks),
        (.weeks, .hours),
        (.hours, .minutes),
        (.minutes, .days),
    ])
    func nextThenCyclesThroughEveryUnit(unit: EventDetailUnit, expected: EventDetailUnit) {
        #expect(unit.next == expected)
    }

    @Test func valueForWeeksThenLeavesARemainderOfDays() {
        #expect(EventDetailUnit.weeks.value(days: 43, target: nil, now: .mockNow) == 6)
        #expect(EventDetailUnit.weeks.remainderDays(days: 43) == 1)
        #expect(EventDetailUnit.weeks.remainderDays(days: 42) == nil)
        #expect(EventDetailUnit.days.remainderDays(days: 43) == nil)
    }

    @Test func valueForHoursAndMinutesThenUsesTheRealInterval() {
        // Given
        let now = Date.mockNow
        let future = now.addingTimeInterval(2 * 86_400 + 3 * 3_600 + 30 * 60)
        let past = now.addingTimeInterval(-90 * 60)

        // Then
        #expect(EventDetailUnit.hours.value(days: 2, target: future, now: now) == 51)
        #expect(EventDetailUnit.minutes.value(days: 2, target: future, now: now) == 3_090)
        #expect(EventDetailUnit.hours.value(days: 0, target: past, now: now) == 1)
        #expect(EventDetailUnit.hours.value(days: 3, target: nil, now: now) == 72)
    }

    @Test(arguments: [
        (EventDetailUnit.days, false),
        (.weeks, false),
        (.hours, true),
        (.minutes, true),
    ])
    func followsTheClockThenHoldsForHoursAndMinutes(unit: EventDetailUnit, expected: Bool) {
        #expect(unit.followsTheClock == expected)
    }
}
