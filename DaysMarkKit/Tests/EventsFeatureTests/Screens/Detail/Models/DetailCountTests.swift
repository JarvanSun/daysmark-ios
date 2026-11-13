//
//  DetailCountTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import EventsFeature

struct DetailCountTests {
    @Test(arguments: [
        (8, EventDetailUnit.days, "detail.count.caption.past.days"),
        (9, .days, "detail.count.caption.past.day"),
        (11, .days, "detail.count.caption.upcoming.day"),
        (12, .days, "detail.count.caption.upcoming.days"),
        (17, .weeks, "detail.count.caption.upcoming.week"),
        (30, .weeks, "detail.count.caption.upcoming.weeks"),
        (12, .hours, "detail.count.caption.upcoming.hours"),
        (12, .minutes, "detail.count.caption.upcoming.minutes"),
        (3, .weeks, "detail.count.caption.past.week"),
        (8, .hours, "detail.count.caption.past.hours"),
        (8, .minutes, "detail.count.caption.past.minutes"),
        (10, .weeks, "detail.count.caption.today"),
    ])
    func captionThenNamesTheUnitTheDirectionAndTheAmount(
        day: Int,
        unit: EventDetailUnit,
        key: String
    ) {
        // Given / When
        let count = makeCount(day: day, unit: unit)

        // Then
        #expect(count.caption.key == key)
    }

    @Test func remainderForWeeksThenShowsTheDaysLeftOver() {
        // Given / When
        let uneven = makeCount(day: 19, unit: .weeks)
        let even = makeCount(day: 24, unit: .weeks)

        // Then
        #expect(uneven.value == 1)
        #expect(uneven.remainderDays == 2)
        #expect(even.remainderDays == nil)
    }

    @Test(arguments: [(8, false), (10, true), (12, true)])
    func countsDownThenHoldsUnlessTheEventHasPassed(day: Int, expected: Bool) {
        #expect(makeCount(day: day, unit: .days).countsDown == expected)
    }

    private func makeCount(day: Int, unit: EventDetailUnit) -> DetailCount {
        unit.count(of: .mock(.mock(day: day)), at: .mockNow)
    }
}
