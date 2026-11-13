//
//  EventDateSpecificationTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import TestSupport
import Testing

@testable import DaysMarkCore

struct EventDateSpecificationTests {
    @Test
    func strictDateWhenTheGregorianDayDoesNotExistThenIsNil() {
        // Given
        let thirtiethOfFebruary = EventDateSpecification(
            calendarSystem: .gregorian,
            year: 2026,
            month: 2,
            day: 30
        )

        // When / Then
        #expect(thirtiethOfFebruary.strictDate(in: .mockUTC) == nil)
    }

    @Test
    func strictDateWhenTheChineseMonthIsALeapMonthThenKeepsIt() throws {
        // Given
        let calendar = Calendar.mockGregorianUTC
        let anchor = Date.mock(2023, 3, 22)
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = .mockUTC
        let components = chinese.dateComponents([.era, .year, .month, .day], from: anchor)
        let specification = EventDateSpecification(
            calendarSystem: .chinese,
            era: components.era,
            year: try #require(components.year),
            month: try #require(components.month),
            day: try #require(components.day),
            isLeapMonth: true
        )

        // When
        let resolved = try #require(specification.strictDate(in: .mockUTC))

        // Then
        #expect(components.month == 2)
        #expect(components.day == 1)
        #expect(components.isLeapMonth == true)
        #expect(
            calendar.dateComponents([.year, .month, .day], from: resolved)
                == DateComponents(year: 2023, month: 3, day: 22)
        )
    }

    @Test
    func strictDateWhenAChineseDateHasNoEraThenIsNil() {
        // Given
        let withoutEra = EventDateSpecification(
            calendarSystem: .chinese,
            year: 40,
            month: 2,
            day: 1,
            isLeapMonth: true
        )

        // When / Then
        #expect(withoutEra.strictDate(in: .mockUTC) == nil)
    }

    @Test
    func strictDateWhenTheCalendarIsUmmAlQuraThenRoundTrips() throws {
        // Given
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = .mockRiyadh
        var islamic = Calendar(identifier: .islamicUmmAlQura)
        islamic.timeZone = .mockRiyadh
        let anchor = Date.mock(2024, 3, 11, in: .mockRiyadh)
        let components = islamic.dateComponents([.era, .year, .month, .day], from: anchor)
        let specification = EventDateSpecification(
            calendarSystem: .islamicUmmAlQura,
            era: components.era,
            year: 1445,
            month: 9,
            day: 1
        )

        // When
        let resolved = try #require(specification.strictDate(in: .mockRiyadh))

        // Then
        #expect(components.year == 1445)
        #expect(components.month == 9)
        #expect(components.day == 1)
        #expect(
            gregorian.dateComponents([.year, .month, .day], from: resolved)
                == DateComponents(year: 2024, month: 3, day: 11)
        )
    }

    @Test
    func resolvedDateThenTellsTheThreeTimeSemanticsApart() throws {
        // Given
        let allDay = EventDateSpecification(
            calendarSystem: .gregorian,
            year: 2026,
            month: 8,
            day: 20
        )
        let timed = EventDateSpecification(
            calendarSystem: .gregorian,
            year: 2026,
            month: 8,
            day: 20,
            hour: 9,
            minute: 0,
            utcOffsetSecondsAtCreation: 2 * 60 * 60
        )
        var tokyoCalendar = Calendar(identifier: .gregorian)
        tokyoCalendar.timeZone = .mockTokyo

        // When
        let floatingDay = try #require(
            allDay.resolvedDate(
                semantics: .floatingAllDay,
                eventTimeZone: .mockBerlin,
                userTimeZone: .mockTokyo
            )
        )
        let fixed = try #require(
            timed.resolvedDate(
                semantics: .fixedInstant,
                eventTimeZone: .mockBerlin,
                userTimeZone: .mockTokyo
            )
        )
        let floatingTime = try #require(
            timed.resolvedDate(
                semantics: .floatingLocalTime,
                eventTimeZone: .mockBerlin,
                userTimeZone: .mockTokyo
            )
        )

        // Then
        #expect(tokyoCalendar.component(.day, from: floatingDay) == 20)
        #expect(tokyoCalendar.component(.hour, from: fixed) == 16)
        #expect(tokyoCalendar.component(.hour, from: floatingTime) == 9)
        #expect(fixed != floatingTime)
    }

    @Test
    func resolvedDateWhenTheWallTimeRepeatsAtTheEndOfSummerTimeThenFollowsTheStoredOffset() throws {
        // Given
        let summerOccurrence = EventDateSpecification(
            calendarSystem: .gregorian,
            year: 2026,
            month: 10,
            day: 25,
            hour: 2,
            minute: 30,
            utcOffsetSecondsAtCreation: 2 * 60 * 60
        )
        var winterOccurrence = summerOccurrence
        winterOccurrence.utcOffsetSecondsAtCreation = 60 * 60

        // When
        let first = try #require(
            summerOccurrence.resolvedDate(
                semantics: .fixedInstant,
                eventTimeZone: .mockBerlin,
                userTimeZone: .mockTokyo
            )
        )
        let second = try #require(
            winterOccurrence.resolvedDate(
                semantics: .fixedInstant,
                eventTimeZone: .mockBerlin,
                userTimeZone: .mockTokyo
            )
        )

        // Then
        #expect(second.timeIntervalSince(first) == 60 * 60)
        #expect(TimeZone.mockBerlin.secondsFromGMT(for: first) == 2 * 60 * 60)
        #expect(TimeZone.mockBerlin.secondsFromGMT(for: second) == 60 * 60)
    }

    @Test
    func resolvedDateWhenTheZoneCrossedTheDateLineThenFollowsTheStoredOffset() throws {
        // Given
        let kwajalein = try #require(TimeZone(identifier: "Pacific/Kwajalein"))
        let beforeTheShift = EventDateSpecification(
            calendarSystem: .gregorian,
            year: 1969,
            month: 9,
            day: 30,
            hour: 12,
            minute: 0,
            utcOffsetSecondsAtCreation: 11 * 60 * 60
        )
        var afterTheShift = beforeTheShift
        afterTheShift.utcOffsetSecondsAtCreation = -12 * 60 * 60

        // When
        let first = try #require(
            beforeTheShift.resolvedDate(
                semantics: .fixedInstant,
                eventTimeZone: kwajalein,
                userTimeZone: .mockUTC
            )
        )
        let second = try #require(
            afterTheShift.resolvedDate(
                semantics: .fixedInstant,
                eventTimeZone: kwajalein,
                userTimeZone: .mockUTC
            )
        )

        // Then
        #expect(second.timeIntervalSince(first) == 23 * 60 * 60)
        #expect(kwajalein.secondsFromGMT(for: first) == 11 * 60 * 60)
        #expect(kwajalein.secondsFromGMT(for: second) == -12 * 60 * 60)
    }

    @Test
    func resolvedDateWhenTheStoredOffsetDisagreesWithTheZoneThenTrustsTheOffset() throws {
        // Given
        let specification = EventDateSpecification(
            calendarSystem: .gregorian,
            year: 2030,
            month: 1,
            day: 1,
            hour: 9,
            minute: 0,
            utcOffsetSecondsAtCreation: 60 * 60
        )

        // When
        let resolved = try #require(
            specification.resolvedDate(
                semantics: .fixedInstant,
                eventTimeZone: .mockTokyo,
                userTimeZone: .mockBerlin
            )
        )

        // Then
        #expect(
            Calendar.mockGregorianUTC.dateComponents([.hour, .minute], from: resolved)
                == DateComponents(hour: 8, minute: 0)
        )
    }

    @Test(arguments: [14, -12])
    func resolvedDateWhenAllDayThenKeepsTheDayInAnExtremeTimeZone(hoursFromGMT: Int) throws {
        // Given
        let zone = try #require(TimeZone(secondsFromGMT: hoursFromGMT * 60 * 60))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let specification = EventDateSpecification(
            calendarSystem: .gregorian,
            year: 2030,
            month: 1,
            day: 1
        )

        // When
        let date = try #require(
            specification.resolvedDate(
                semantics: .floatingAllDay,
                eventTimeZone: nil,
                userTimeZone: zone
            )
        )

        // Then
        #expect(
            calendar.dateComponents([.year, .month, .day], from: date)
                == DateComponents(year: 2030, month: 1, day: 1)
        )
    }
}
