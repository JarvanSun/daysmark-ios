//
//  EventSorterTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct EventSorterTests {
    private let sorter = EventSorter()
    private let utc = TimeZone(identifier: "UTC")!

    @Test
    func proximitySortsUpcomingBeforePast() throws {
        let events = [
            event("far future", 12, 25),
            event("near past", 8, 18),
            event("near future", 8, 22),
        ]

        let sorted = sorter.sorted(events, now: try now(), userTimeZone: utc)

        #expect(titles(sorted) == ["near future", "far future", "near past"])
    }

    @Test
    func todaySortsFirst() throws {
        let events = [event("tomorrow", 8, 21), event("today", 8, 20)]

        let sorted = sorter.sorted(events, now: try now(), userTimeZone: utc)

        #expect(titles(sorted) == ["today", "tomorrow"])
    }

    @Test
    func equalDistancesSortStablyByTitle() throws {
        let events = [event("Bravo", 8, 22), event("Alpha", 8, 22)]

        let sorted = sorter.sorted(events, now: try now(), userTimeZone: utc)

        #expect(titles(sorted) == ["Alpha", "Bravo"])
    }

    @Test
    func dropsEventsWithUnresolvableDates() throws {
        let broken = CountdownEvent.mock(
            title: "broken",
            year: 2026,
            month: 13,
            day: 40,
            timeZone: utc
        )
        let events = [broken, event("valid", 8, 22)]

        let sorted = sorter.sorted(events, now: try now(), userTimeZone: utc)

        #expect(titles(sorted) == ["valid"])
    }

    @Test
    func countedResultFeedsBothOrderingAndHero() throws {
        let events = [event("far", 12, 25), event("near", 8, 22)]

        let counted = sorter.counted(events, now: try now(), userTimeZone: utc)
        let ordered = sorter.ordered(counted)
        let hero = sorter.focus(among: counted, focusedEventID: events[1].id)

        #expect(counted.count == 2)
        #expect(titles(ordered) == ["near", "far"])
        #expect(hero?.event.title == "near")

        #expect(titles(ordered) == titles(sorter.sorted(events, now: try now(), userTimeZone: utc)))
    }

    @Test
    func emptyInputReturnsEmpty() throws {
        #expect(sorter.sorted([], now: try now(), userTimeZone: utc).isEmpty)
    }

    @Test
    func staleSelectionFallsBackToAll() {
        let work = EventCategory(builtIn: .birthday)
        let removed = EventCategory(builtIn: .important)

        #expect(sorter.effectiveFilter(removed.id, in: [work]) == nil)
    }

    @Test
    func liveSelectionIsKept() {
        let work = EventCategory(builtIn: .birthday)

        #expect(sorter.effectiveFilter(work.id, in: [work]) == work.id)
    }

    @Test
    func nilSelectionStaysNil() {
        #expect(sorter.effectiveFilter(nil, in: [EventCategory(builtIn: .birthday)]) == nil)
    }

    @Test
    func heroPrefersFocusOverNearer() throws {
        let events = [
            event("tomorrow", 8, 21),
            event("far but pinned", 12, 25),
        ]

        let hero = sorter.focus(
            in: events,
            now: try now(),
            userTimeZone: utc,
            focusedEventID: events[1].id
        )

        #expect(hero?.event.title == "far but pinned")
    }

    @Test
    func heroFallsBackToNearestWhenNothingPinned() throws {
        let events = [event("far", 12, 25), event("near", 8, 22)]

        let hero = sorter.focus(
            in: events,
            now: try now(),
            userTimeZone: utc,
            focusedEventID: nil
        )

        #expect(hero?.event.title == "near")
    }

    @Test
    func heroIsNilWhenThereAreNoEvents() throws {
        #expect(
            sorter.focus(in: [], now: try now(), userTimeZone: utc, focusedEventID: nil) == nil
        )
    }

    @Test
    func heroSkipsUnresolvableFocusedEvent() throws {
        let broken = CountdownEvent.mock(
            title: "broken",
            year: 2026,
            month: 13,
            day: 40,
            timeZone: utc
        )
        let events = [broken, event("valid", 8, 22)]

        let hero = sorter.focus(
            in: events,
            now: try now(),
            userTimeZone: utc,
            focusedEventID: broken.id
        )

        #expect(hero?.event.title == "valid")
    }

    @Test
    func resultCarriesTheDayCount() throws {
        let sorted = sorter.sorted(
            [event("in two days", 8, 22)],
            now: try now(),
            userTimeZone: utc
        )

        #expect(sorted.first?.dayCount == DayCount(days: 2, direction: .upcoming))
    }

    @Test
    func theOccurrenceMatchesTheOneUsedForTheCount() throws {
        let sorter = EventSorter()

        let event = CountdownEvent.mock(
            title: "birthday",
            year: 2000,
            month: 3,
            day: 9,
            timeZone: utc,
            repeatRule: .yearly
        )

        let counted = try #require(
            sorter.counted([event], now: try now(), userTimeZone: utc).first
        )

        #expect(counted.occurrence.year == 2027, "The next occurrence must use the resolved year")
        #expect(counted.occurrence.month == 3)
        #expect(counted.occurrence.day == 9)

        let recomputed = DayCountCalculator(calendar: Calendar(identifier: .gregorian)).dayCount(
            targetDay: counted.occurrence,
            countsFromDayOne: event.countsFromDayOne,
            now: try now(),
            userTimeZone: utc
        )
        #expect(recomputed == counted.dayCount)
    }
}

private extension EventSorterTests {
    func now() throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        return try #require(
            calendar.date(from: DateComponents(year: 2026, month: 8, day: 20, hour: 12))
        )
    }

    func event(
        _ title: String,
        _ month: Int,
        _ day: Int
    ) -> CountdownEvent {
        CountdownEvent.mock(
            title: title,
            year: 2026,
            month: month,
            day: day,
            timeZone: utc
        )
    }

    func titles(_ items: [EventDayCount]) -> [String] {
        items.map(\.event.title)
    }
}
