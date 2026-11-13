//
//  EventRangeSpecificationTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct EventRangeSpecificationTests {
    @Test
    func measureWhenTheRangeCrossesTheStartOfSummerTimeThenCountsDaysOrElapsedTime() {
        // Given
        let allDay = EventRangeSpecification(
            start: EventDateSpecification(
                calendarSystem: .gregorian,
                year: 2026,
                month: 3,
                day: 28
            ),
            end: EventDateSpecification(calendarSystem: .gregorian, year: 2026, month: 3, day: 30),
            semantics: .floatingAllDay
        )
        let fixed = EventRangeSpecification(
            start: EventDateSpecification(
                calendarSystem: .gregorian,
                year: 2026,
                month: 3,
                day: 28,
                hour: 9,
                minute: 0,
                utcOffsetSecondsAtCreation: 60 * 60
            ),
            end: EventDateSpecification(
                calendarSystem: .gregorian,
                year: 2026,
                month: 3,
                day: 30,
                hour: 9,
                minute: 0,
                utcOffsetSecondsAtCreation: 2 * 60 * 60
            ),
            semantics: .fixedInstant
        )

        // When
        let days = allDay.measure(eventTimeZone: .mockBerlin, userTimeZone: .mockBerlin)
        let duration = fixed.measure(eventTimeZone: .mockBerlin, userTimeZone: .mockTokyo)

        // Then
        #expect(days == .calendarDays(2))
        #expect(duration == .duration(47 * 60 * 60))
    }
}
