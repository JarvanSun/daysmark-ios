//
//  DayCountCalculatorTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct DayCountCalculatorTests {
    private let calculator = DayCountCalculator(calendar: Calendar(identifier: .gregorian))

    @Test
    func futureTargetCountsDown() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))

        let result = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: try date(2026, 8, 10, timeZone: utc),
            userTimeZone: utc
        )

        #expect(result == DayCount(days: 10, direction: .upcoming))
    }

    @Test
    func todayIsZero() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))

        let result = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: try date(2026, 8, 20, hour: 23, minute: 59, timeZone: utc),
            userTimeZone: utc
        )

        #expect(result == DayCount(days: 0, direction: .today))
    }

    @Test
    func pastTargetCountsUp() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))

        let result = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: try date(2026, 8, 25, timeZone: utc),
            userTimeZone: utc
        )

        #expect(result == DayCount(days: 5, direction: .past))
    }

    @Test
    func countsFromDayOneAddsStartDay() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let now = try date(2026, 8, 23, timeZone: utc)

        let plain = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: now,
            userTimeZone: utc
        )
        let inclusive = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: true,
            now: now,
            userTimeZone: utc
        )

        #expect(plain?.days == 3)
        #expect(inclusive?.days == 4)
    }

    @Test
    func countsFromDayOneDoesNotAffectUpcoming() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let now = try date(2026, 8, 10, timeZone: utc)

        let plain = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: now,
            userTimeZone: utc
        )
        let inclusive = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: true,
            now: now,
            userTimeZone: utc
        )

        #expect(plain == inclusive)
        #expect(plain?.days == 10)
    }

    @Test
    func springForwardDoesNotSkewCount() throws {

        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))

        let result = calculator.dayCount(
            targetDay: target(2026, 3, 30),
            countsFromDayOne: false,
            now: try date(2026, 3, 28, timeZone: berlin),
            userTimeZone: berlin
        )

        #expect(result == DayCount(days: 2, direction: .upcoming))
    }

    @Test
    func fallBackDoesNotSkewCount() throws {

        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))

        let result = calculator.dayCount(
            targetDay: target(2026, 10, 26),
            countsFromDayOne: false,
            now: try date(2026, 10, 24, timeZone: berlin),
            userTimeZone: berlin
        )

        #expect(result == DayCount(days: 2, direction: .upcoming))
    }

    @Test
    func extremePositiveOffsetTimeZone() throws {
        let kiritimati = try #require(TimeZone(identifier: "Pacific/Kiritimati"))

        let result = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: try date(2026, 8, 20, hour: 1, timeZone: kiritimati),
            userTimeZone: kiritimati
        )

        #expect(result?.direction == .today)
    }

    @Test
    func extremeNegativeOffsetTimeZone() throws {
        let midway = try #require(TimeZone(identifier: "Pacific/Midway"))

        let result = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: try date(2026, 8, 20, hour: 23, timeZone: midway),
            userTimeZone: midway
        )

        #expect(result?.direction == .today)
    }

    @Test
    func sameInstantDiffersByUserTimeZone() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))

        let instant = try date(2026, 8, 19, hour: 22, timeZone: utc)

        let inUTC = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: instant,
            userTimeZone: utc
        )
        let inTokyo = calculator.dayCount(
            targetDay: target(2026, 8, 20),
            countsFromDayOne: false,
            now: instant,
            userTimeZone: tokyo
        )

        #expect(inUTC == DayCount(days: 1, direction: .upcoming))
        #expect(inTokyo?.direction == .today)
    }

    @Test
    func leapDayTarget() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))

        let result = calculator.dayCount(
            targetDay: target(2028, 2, 29),
            countsFromDayOne: false,
            now: try date(2028, 2, 27, timeZone: utc),
            userTimeZone: utc
        )

        #expect(result == DayCount(days: 2, direction: .upcoming))
    }

    @Test
    func spanningLeapFebruary() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))

        let result = calculator.dayCount(
            targetDay: target(2028, 3, 1),
            countsFromDayOne: false,
            now: try date(2028, 2, 28, timeZone: utc),
            userTimeZone: utc
        )

        #expect(result == DayCount(days: 2, direction: .upcoming))
    }

    @Test
    func spanningYearBoundary() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))

        let result = calculator.dayCount(
            targetDay: target(2027, 1, 1),
            countsFromDayOne: false,
            now: try date(2026, 12, 30, timeZone: utc),
            userTimeZone: utc
        )

        #expect(result == DayCount(days: 2, direction: .upcoming))
    }

    @Test
    func incompleteComponentsReturnNil() {
        let result = calculator.dayCount(
            targetDay: DateComponents(month: 8, day: 20),
            countsFromDayOne: false,
            now: .mockNow,
            userTimeZone: .mockUTC
        )

        #expect(result == nil)
    }

    @Test
    func rolledOverDatesReturnNil() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let now = try date(2026, 1, 1, timeZone: utc)

        #expect(
            calculator.dayCount(
                targetDay: target(2026, 2, 30),
                countsFromDayOne: false,
                now: now,
                userTimeZone: utc
            ) == nil
        )
        #expect(
            calculator.dayCount(
                targetDay: target(2026, 13, 1),
                countsFromDayOne: false,
                now: now,
                userTimeZone: utc
            ) == nil
        )
        #expect(
            calculator.dayCount(
                targetDay: target(2026, 2, 29),
                countsFromDayOne: false,
                now: now,
                userTimeZone: utc
            ) == nil
        )
    }

    @Test
    func leapDayValidOnlyInLeapYears() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let now = try date(2026, 1, 1, timeZone: utc)

        #expect(
            calculator.dayCount(
                targetDay: target(2027, 2, 29),
                countsFromDayOne: false,
                now: now,
                userTimeZone: utc
            ) == nil
        )
        #expect(
            calculator.dayCount(
                targetDay: target(2028, 2, 29),
                countsFromDayOne: false,
                now: now,
                userTimeZone: utc
            ) != nil
        )
    }

    @Test
    func eventTimeZoneIsIgnoredForDayCount() throws {
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let event = CountdownEvent.mock(
            title: "妈妈生日",
            year: 2026,
            month: 8,
            day: 20,
            timeZone: berlin
        )

        let counted = EventSorter().counted(
            [event],
            now: try date(2026, 8, 20, hour: 6, timeZone: tokyo),
            userTimeZone: tokyo
        )

        #expect(counted.first?.dayCount.direction == .today)
    }

    @Test
    func countsFromDayOneIsForwardedFromTheEvent() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let event = CountdownEvent.mock(
            title: "在一起",
            year: 2026,
            month: 8,
            day: 20,
            countsFromDayOne: true
        )

        let counted = EventSorter().counted(
            [event],
            now: try date(2026, 8, 23, timeZone: utc),
            userTimeZone: utc
        )

        #expect(counted.first?.dayCount == DayCount(days: 4, direction: .past))
    }
}

private extension DayCountCalculatorTests {
    func date(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 12,
        minute: Int = 0,
        timeZone: TimeZone
    ) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )
        return try #require(calendar.date(from: components))
    }

    func target(_ year: Int, _ month: Int, _ day: Int) -> DateComponents {
        DateComponents(year: year, month: month, day: day)
    }
}
