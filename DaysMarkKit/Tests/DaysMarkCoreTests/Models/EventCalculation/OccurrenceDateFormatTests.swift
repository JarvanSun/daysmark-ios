//
//  OccurrenceDateFormatTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/08/01.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct OccurrenceDateFormatTests {
    @Test
    func textWhenTheOccurrenceIsInTheCurrentYearThenOmitsTheYear() throws {
        // Given / When
        let result = try #require(text(2026, 9, 20, now: .mock(2026, 8, 1)))

        // Then
        #expect(!result.contains("2026"))
        #expect(result.contains("20"))
    }

    @Test(arguments: [2029, 2016])
    func textWhenTheOccurrenceIsInAnotherYearThenShowsTheYear(year: Int) throws {
        // Given / When
        let result = try #require(text(year, 9, 20, now: .mock(2026, 8, 1)))

        // Then
        #expect(result.contains(String(year)))
    }

    @Test
    func textThenDecidesByCalendarYearNotByDistance() throws {
        // Given / When
        let newYearsEve = try #require(text(2026, 12, 31, now: .mock(2026, 1, 1)))
        let nextDay = try #require(text(2027, 1, 1, now: .mock(2026, 12, 31)))

        // Then
        #expect(!newYearsEve.contains("2026"))
        #expect(nextDay.contains("2027"))
    }

    @Test(arguments: [DateComponents(year: 2026, month: 13, day: 40), DateComponents(year: 2026)])
    func textWhenTheOccurrenceIsNotADateThenIsNil(occurrence: DateComponents) {
        #expect(format(now: .mockNow).text(for: item(occurrence: occurrence)) == nil)
    }

    @Test
    func textWhenTheOccurrenceDateIsResolvedThenFormatsItInTheGivenLocaleAndTimeZone() throws {
        // Given
        let resolved = item(occurrence: DateComponents(), resolvedOn: .mock(2029, 9, 20))

        // When
        let result = try #require(format(now: .mock(2026, 8, 1)).text(for: resolved))

        // Then
        #expect(result == "Sep 20, 2029")
    }

    private func format(now: Date) -> OccurrenceDateFormat {
        OccurrenceDateFormat(now: now, userTimeZone: .mockUTC, locale: Locale(identifier: "en_US"))
    }

    private func text(_ year: Int, _ month: Int, _ day: Int, now: Date) -> String? {
        format(now: now).text(
            for: item(occurrence: DateComponents(year: year, month: month, day: day))
        )
    }

    private func item(occurrence: DateComponents, resolvedOn date: Date? = nil) -> EventDayCount {
        EventDayCount(
            event: .mock(),
            dayCount: DayCount(days: 1, direction: .upcoming),
            occurrence: occurrence,
            resolvedOccurrenceDate: date
        )
    }
}
