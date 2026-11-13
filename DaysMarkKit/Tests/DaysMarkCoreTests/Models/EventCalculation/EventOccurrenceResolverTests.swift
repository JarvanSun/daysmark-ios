//
//  EventOccurrenceResolverTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct EventOccurrenceResolverTests {
    private let resolver = EventOccurrenceResolver()
    private let utc = TimeZone(secondsFromGMT: 0)!
    private let berlin = TimeZone(identifier: "Europe/Berlin")!

    @Test
    func monthlySkipsInvalidDay() throws {
        let event = CountdownEvent.mock(
            title: "Month end",
            year: 2026,
            month: 1,
            day: 31,
            timeZone: utc,
            repeatRule: .monthly
        )
        let now = try #require(gregorianDate(2026, 2, 1, in: utc))
        let occurrence = try #require(
            resolver.nextOccurrence(for: event, now: now, userTimeZone: utc)
        )
        #expect(occurrence.start.year == 2026)
        #expect(occurrence.start.month == 3)
        #expect(occurrence.start.day == 31)
    }

    @Test
    func fixedRepeatRecomputesOffset() throws {
        let event = CountdownEvent.mock(
            title: "Berlin meeting",
            year: 2026,
            month: 3,
            day: 28,
            hour: 9,
            minute: 0,
            timeZone: berlin,
            repeatRule: .yearly
        )
        let now = try #require(gregorianDate(2027, 1, 1, in: berlin))
        let occurrence = try #require(
            resolver.nextOccurrence(for: event, now: now, userTimeZone: utc)
        )
        #expect(occurrence.start.year == 2027)
        #expect(occurrence.start.hour == 9)
        #expect(occurrence.start.utcOffsetSecondsAtCreation == 2 * 60 * 60)
    }

    @Test
    func ongoingAllDayRangeUsesEndBoundary() throws {
        let event = CountdownEvent.mock(
            title: "Trip",
            year: 2026,
            month: 3,
            day: 28,
            timeZone: berlin,
            endYear: 2026,
            endMonth: 3,
            endDay: 30,
            repeatRule: .yearly
        )
        let now = try #require(gregorianDate(2026, 3, 29, hour: 12, in: berlin))
        let occurrence = try #require(
            resolver.nextOccurrence(for: event, now: now, userTimeZone: berlin)
        )
        #expect(occurrence.start.day == 28)
        #expect(occurrence.end?.day == 30)
        let reference = occurrence.referenceDate(
            now: now,
            semantics: .floatingAllDay,
            userTimeZone: berlin
        )
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = berlin
        #expect(calendar.component(.day, from: reference) == 30)
    }

    @Test
    func fixedRangePreservesDuration() throws {
        let event = CountdownEvent.mock(
            title: "DST range",
            year: 2026,
            month: 3,
            day: 28,
            hour: 9,
            minute: 0,
            timeZone: berlin
        )
        event.rangeDurationSeconds = 47 * 60 * 60
        let before = try #require(gregorianDate(2026, 3, 28, hour: 8, in: berlin))
        let occurrence = try #require(
            resolver.nextOccurrence(for: event, now: before, userTimeZone: utc)
        )
        let end = try #require(occurrence.endDate)
        #expect(end.timeIntervalSince(occurrence.startDate) == 47 * 60 * 60)
    }

    @Test
    func ummAlQuraRepeatUsesSelectedCalendar() throws {
        let riyadh = try #require(TimeZone(identifier: "Asia/Riyadh"))
        var islamic = Calendar(identifier: .islamicUmmAlQura)
        islamic.timeZone = riyadh
        let anchor = try #require(gregorianDate(2024, 3, 11, hour: 12, in: riyadh))
        let parts = islamic.dateComponents([.era, .year, .month, .day], from: anchor)
        let event = CountdownEvent.mock(
            title: "Ramadan",
            year: try #require(parts.year),
            month: try #require(parts.month),
            day: try #require(parts.day),
            timeZone: riyadh,
            repeatRule: .yearly,
            calendarSystem: .islamicUmmAlQura
        )
        event.targetEra = parts.era
        let now = try #require(gregorianDate(2025, 2, 1, in: riyadh))
        let occurrence = try #require(
            resolver.nextOccurrence(for: event, now: now, userTimeZone: riyadh)
        )
        #expect(occurrence.start.calendarSystem == .islamicUmmAlQura)
        #expect(occurrence.start.year == 1446)
        #expect(occurrence.start.month == 9)
        #expect(occurrence.start.day == 1)
    }

    @Test
    func chineseLeapMonthSearchesTheFullCalendarCycle() throws {
        let anchor = try #require(gregorianDate(2023, 3, 22, in: utc))
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = utc
        let parts = chinese.dateComponents([.era, .year, .month, .day], from: anchor)
        let event = CountdownEvent.mock(
            title: "Leap month",
            year: try #require(parts.year),
            month: try #require(parts.month),
            day: try #require(parts.day),
            timeZone: utc,
            repeatRule: .yearly,
            calendarSystem: .chinese
        )
        event.targetEra = parts.era
        event.targetIsLeapMonth = true
        let now = try #require(gregorianDate(2024, 1, 1, in: utc))

        let occurrence = try #require(
            resolver.nextOccurrence(for: event, now: now, userTimeZone: utc)
        )
        let gregorian = Calendar(identifier: .gregorian).dateComponents(
            [.year, .month, .day],
            from: occurrence.startDate
        )

        #expect(occurrence.start.isLeapMonth)
        #expect(gregorian.year == 2042)
        #expect(gregorian.month == 3)
        #expect(gregorian.day == 22)
    }

    private func gregorianDate(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 0,
        in timeZone: TimeZone
    ) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(
            from: DateComponents(year: year, month: month, day: day, hour: hour)
        )
    }
}
