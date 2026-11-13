//
//  WidgetTimelinePlannerTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/08/01.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct WidgetTimelinePlannerTests {
    private let berlin = TimeZone(identifier: "Europe/Berlin")!
    @Test
    func firstEntryIsNowAndTheRestAreLocalMidnight() throws {
        let now = try date(2026, 8, 1, 14, in: berlin)

        let dates = WidgetTimelinePlanner(timeZone: berlin, dayCount: 3).entryDates(from: now)

        #expect(dates.first == now)
        for entry in dates.dropFirst() {
            let components = calendar(berlin).dateComponents(
                [.hour, .minute, .second],
                from: entry
            )
            #expect(components.hour == 0 && components.minute == 0 && components.second == 0)
        }
    }

    @Test
    func returnsTheRequestedNumberOfEntries() throws {
        let now = try date(2026, 8, 1, in: berlin)

        #expect(
            WidgetTimelinePlanner(timeZone: berlin, dayCount: 7).entryDates(from: now).count == 7
        )
        #expect(
            WidgetTimelinePlanner(timeZone: berlin, dayCount: 1).entryDates(from: now).count == 1
        )
    }

    @Test
    func datesAreStrictlyIncreasing() throws {
        let dates = WidgetTimelinePlanner(timeZone: berlin, dayCount: 7).entryDates(
            from: try date(2026, 8, 1, 23, in: berlin)
        )

        for (earlier, later) in zip(dates, dates.dropFirst()) {
            #expect(earlier < later)
        }
    }

    @Test
    func zeroDaysProducesNothing() throws {
        #expect(
            WidgetTimelinePlanner(timeZone: berlin, dayCount: 0)
                .entryDates(from: try date(2026, 8, 1, in: berlin)).isEmpty
        )
    }

    @Test
    func springForwardDayIsTwentyThreeHours() throws {

        let dates = WidgetTimelinePlanner(timeZone: berlin, dayCount: 5).entryDates(
            from: try date(2026, 3, 27, 12, in: berlin)
        )

        let gaps = zip(dates.dropFirst(), dates.dropFirst(2)).map { $1.timeIntervalSince($0) }
        #expect(
            gaps.contains(23 * 3600),
            "Expected a 23-hour day; actual hours: \(gaps.map { $0 / 3600 })"
        )
    }

    @Test
    func fallBackDayIsTwentyFiveHours() throws {

        let dates = WidgetTimelinePlanner(timeZone: berlin, dayCount: 5).entryDates(
            from: try date(2026, 10, 23, 12, in: berlin)
        )

        let gaps = zip(dates.dropFirst(), dates.dropFirst(2)).map { $1.timeIntervalSince($0) }
        #expect(
            gaps.contains(25 * 3600),
            "Expected a 25-hour day; actual hours: \(gaps.map { $0 / 3600 })"
        )
    }

    @Test
    func dayCountsFollowTheEntryDate() throws {
        let utc = TimeZone(identifier: "UTC")!
        let now = try date(2026, 8, 1, 12, in: utc)
        let event = CountdownEvent.mock(title: "trip", year: 2026, month: 8, day: 3, timeZone: utc)

        let counts = WidgetTimelinePlanner(timeZone: utc, dayCount: 5).entryDates(from: now).map {
            date in
            EventSorter().counted([event], now: date, userTimeZone: utc).first?.dayCount
        }

        #expect(counts.map(\.?.days) == [2, 1, 0, 1, 2])
        #expect(counts.map(\.?.direction) == [.upcoming, .upcoming, .today, .past, .past])
    }

    @Test
    func repeatingEventsRollToTheNextOccurrence() throws {
        let utc = TimeZone(identifier: "UTC")!
        let now = try date(2026, 8, 1, 12, in: utc)
        let event = CountdownEvent.mock(
            title: "birthday",
            year: 2000,
            month: 8,
            day: 2,
            timeZone: utc,
            repeatRule: .yearly
        )

        let counts = WidgetTimelinePlanner(timeZone: utc, dayCount: 4).entryDates(from: now).map {
            date in
            EventSorter().counted([event], now: date, userTimeZone: utc).first?.dayCount
        }

        #expect(counts.map(\.?.days) == [1, 0, 364, 363])
        #expect(counts.map(\.?.direction) == [.upcoming, .today, .upcoming, .upcoming])
    }

    @Test
    func timedRangeAddsPhaseBoundaries() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let now = try #require(
            calendar(utc).date(
                from: DateComponents(year: 2026, month: 8, day: 1, hour: 9)
            )
        )
        let start = try #require(
            calendar(utc).date(
                from: DateComponents(year: 2026, month: 8, day: 1, hour: 10)
            )
        )
        let end = try #require(
            calendar(utc).date(
                from: DateComponents(year: 2026, month: 8, day: 1, hour: 11)
            )
        )
        let event = CountdownEvent.mock(
            title: "Meeting",
            year: 2026,
            month: 8,
            day: 1,
            hour: 10,
            minute: 0,
            timeZone: utc,
            timeSemantics: .fixedInstant
        )
        event.rangeDurationSeconds = 3_600

        let dates = WidgetTimelinePlanner(timeZone: utc, dayCount: 2).entryDates(
            from: now,
            events: [event]
        )

        #expect(dates.contains(start))
        #expect(dates.contains(end.addingTimeInterval(1)))
        #expect(dates == dates.sorted())
        #expect(Set(dates).count == dates.count)
    }

    @Test
    func fixedInstantAddsEventTimeZoneDayBoundary() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let now = try #require(
            calendar(utc).date(
                from: DateComponents(year: 2026, month: 8, day: 1, hour: 12)
            )
        )
        let eventDayStart = try #require(
            calendar(utc).date(
                from: DateComponents(year: 2026, month: 8, day: 1, hour: 15)
            )
        )
        let event = CountdownEvent.mock(
            title: "Tokyo concert",
            year: 2026,
            month: 8,
            day: 2,
            hour: 21,
            minute: 0,
            timeZone: tokyo,
            timeSemantics: .fixedInstant
        )

        let dates = WidgetTimelinePlanner(timeZone: utc, dayCount: 2).entryDates(
            from: now,
            events: [event]
        )

        #expect(dates.contains(eventDayStart))
    }

    @Test("many timed events stay within the entry cap")
    func manyTimedEventsAreCapped() throws {
        let utc = TimeZone(secondsFromGMT: 0)!
        let now = try date(2026, 8, 1, 0, in: utc)
        let events = (0..<500).map { index in
            CountdownEvent.mock(
                title: "Timed \(index)",
                year: 2000,
                month: 8,
                day: 1 + index % 7,
                hour: index % 24,
                minute: index % 60,
                timeZone: utc,
                repeatRule: .yearly,
                timeSemantics: .floatingLocalTime
            )
        }

        let dates = WidgetTimelinePlanner(timeZone: utc, dayCount: 7).entryDates(
            from: now,
            events: events
        )

        #expect(dates.count == WidgetTimelinePlanner(timeZone: utc).entryLimit)
        #expect(dates.first == now)
        #expect(dates == dates.sorted())
    }
}

private extension WidgetTimelinePlannerTests {
    func calendar(_ zone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        return calendar
    }

    func date(
        _ y: Int,
        _ m: Int,
        _ d: Int,
        _ h: Int = 12,
        in zone: TimeZone
    ) throws -> Date {
        try #require(calendar(zone).date(from: DateComponents(year: y, month: m, day: d, hour: h)))
    }
}
