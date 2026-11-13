//
//  WidgetContentResolverTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/04.
//

import Foundation
import Testing
import WidgetKit

@testable import DaysMarkCore

@MainActor
struct WidgetContentResolverTests {
    @Test(arguments: WidgetFamily.mockSupported)
    func contentWhenTheSourceIsTheAutomaticFocusThenShowsTheSelectedEvent(family: WidgetFamily) {
        // Given
        let nearest = makeEvent("Nearest", onDay: 5)
        let selected = makeEvent("Selected", onDay: 20)
        let store = WidgetStoreContents.mock(events: [nearest, selected], focus: selected.id)

        // When
        let content = makeResolver().content(for: makeRequest(.automaticFocus, family), in: store)

        // Then
        #expect(
            content
                == WidgetContent(
                    date: .mock(2026, 9, 4),
                    display: .event(
                        WidgetRow(
                            id: selected.id,
                            title: "Selected",
                            phrase: RelativeTimePhrase(DayCount(days: 16, direction: .upcoming)),
                            dateText: "Sep 20, 2026",
                            direction: .upcoming
                        )
                    ),
                    link: .event(selected.id)
                )
        )
    }

    @Test
    func contentWhenNoFocusIsSelectedThenShowsTheNearestEvent() {
        // Given
        let nearest = makeEvent("Nearest", onDay: 5)
        let store = WidgetStoreContents.mock(events: [makeEvent("Later", onDay: 20), nearest])

        // When
        let content = makeResolver().content(for: makeRequest(.automaticFocus), in: store)

        // Then
        #expect(content.display.rows.map(\.id) == [nearest.id])
    }

    @Test
    func contentWhenTheAutomaticFocusHasNoEventsThenIsUnavailableAndOpensAllEvents() {
        // Given / When
        let content = makeResolver().content(
            for: makeRequest(.automaticFocus),
            in: .mock(events: [])
        )

        // Then
        #expect(content.display == .unavailable(.noEvents))
        #expect(content.link == .collection(.all))
    }

    @Test(arguments: WidgetFamily.mockSupported)
    func contentWhenTheSourceIsOneEventThenShowsOnlyThatEvent(family: WidgetFamily) {
        // Given
        let chosen = makeEvent("Chosen", onDay: 20)
        let store = WidgetStoreContents.mock(events: [makeEvent("Nearest", onDay: 5), chosen])

        // When
        let content = makeResolver().content(for: makeRequest(.event(chosen.id), family), in: store)

        // Then
        #expect(content.display.rows.map(\.title) == ["Chosen"])
        #expect(content.display.isList == false)
        #expect(content.link == .event(chosen.id))
    }

    @Test
    func contentWhenTheChosenEventIsDeletedThenIsUnavailableAndNeverShowsAnotherEvent() {
        // Given
        let chosen = makeEvent("Chosen", onDay: 20)
        chosen.deletedAt = .mockNow
        let store = WidgetStoreContents.mock(events: [chosen, makeEvent("Other", onDay: 5)])

        // When
        let content = makeResolver().content(for: makeRequest(.event(chosen.id)), in: store)

        // Then
        #expect(content.display == .unavailable(.missingSource))
        #expect(content.link == .event(chosen.id))
    }

    @Test(arguments: [WidgetContentSource.event(nil), .category(nil)])
    func contentWhenNothingWasChosenThenIsUnavailableAndOpensTheWidgetInstructions(
        source: WidgetContentSource
    ) {
        // Given
        let store = WidgetStoreContents.mock(events: [makeEvent("Other", onDay: 5)])

        // When
        let content = makeResolver().content(for: makeRequest(source), in: store)

        // Then
        #expect(content.display == .unavailable(.missingSource))
        #expect(content.link == .widgets)
    }

    @Test
    func contentWhenTheChosenCategoryIsDeletedThenIsUnavailable() {
        // Given
        let travel = EventCategory(name: "Travel")
        travel.deletedAt = .mockNow
        let store = WidgetStoreContents.mock(
            events: [makeEvent("Trip", onDay: 10)],
            categories: [travel]
        )

        // When
        let content = makeResolver().content(for: makeRequest(.category(travel.id)), in: store)

        // Then
        #expect(content.display == .unavailable(.missingSource))
        #expect(content.link == .category(travel.id))
    }

    @Test
    func contentWhenTheChosenCategoryHasNoEventsThenIsUnavailableAndOpensTheCategory() {
        // Given
        let travel = EventCategory(name: "Travel")
        let store = WidgetStoreContents.mock(
            events: [makeEvent("Dentist", onDay: 10)],
            categories: [travel]
        )

        // When
        let content = makeResolver().content(for: makeRequest(.category(travel.id)), in: store)

        // Then
        #expect(content.display == .unavailable(.noEvents))
        #expect(content.link == .category(travel.id))
    }

    @Test(arguments: [(WidgetFamily.systemMedium, 3), (.systemLarge, 6)])
    func contentWhenAListFamilyShowsACategoryThenListsItsEventsInHomeOrder(
        family: WidgetFamily,
        limit: Int
    ) {
        // Given
        let travel = EventCategory(name: "Travel")
        let trips = (1...8).map { makeEvent("Trip \($0)", onDay: 30 - $0, category: travel) }
        let store = WidgetStoreContents.mock(
            events: trips + [makeEvent("Dentist", onDay: 5)],
            categories: [travel]
        )

        // When
        let content = makeResolver().content(
            for: makeRequest(.category(travel.id), family),
            in: store
        )

        // Then
        #expect(content.display.isList)
        #expect(content.display.rows.map(\.title) == trips.reversed().prefix(limit).map(\.title))
        #expect(content.link == .category(travel.id))
    }

    @Test(arguments: [(WidgetFamily.systemMedium, 3), (.systemLarge, 6)])
    func contentWhenAListFamilyShowsAllEventsThenUsesTheSorterAndTheFamilyLimit(
        family: WidgetFamily,
        limit: Int
    ) {
        // Given
        let events = (1...8).map { makeEvent("Event \($0)", onDay: 4 + $0) }
        let past = makeEvent("Past", onDay: 1)
        let expected = EventSorter()
            .sorted(events + [past], now: .mock(2026, 9, 4), userTimeZone: .mockUTC)
            .prefix(limit)
            .map(\.id)

        // When
        let content = makeResolver().content(
            for: makeRequest(.allEvents, family),
            in: .mock(events: [past] + events)
        )

        // Then
        #expect(content.display.isList)
        #expect(content.display.rows.map(\.id) == expected)
        #expect(content.display.rows.map(\.direction).contains(.past) == false)
        #expect(content.link == .collection(.all))
    }

    @Test(
        arguments: [
            WidgetFamily.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline,
        ],
        [WidgetContentSource.allEvents, .category(BuiltInCategory.important.id)]
    )
    func contentWhenASingleEventFamilyShowsAListSourceThenShowsItsFirstEvent(
        family: WidgetFamily,
        source: WidgetContentSource
    ) {
        // Given
        let first = makeEvent("First", onDay: 5)
        let store = WidgetStoreContents.mock(
            events: [makeEvent("Second", onDay: 9), first],
            categories: [EventCategory(id: BuiltInCategory.important.id, name: "Important")]
        )

        // When
        let content = makeResolver().content(for: makeRequest(source, family), in: store)

        // Then
        #expect(content.display.rows.map(\.id) == [first.id])
        #expect(content.display.isList == false)
        #expect(content.link == .event(first.id))
    }

    @Test
    func contentWhenARepeatingEventHasPassedThenShowsItsNextOccurrence() {
        // Given
        let birthday = CountdownEvent.mock(
            title: "Birthday",
            year: 2000,
            month: 9,
            day: 5,
            timeZone: .mockUTC,
            repeatRule: .yearly
        )
        let request = WidgetContentRequest(
            source: .event(birthday.id),
            family: .systemSmall,
            now: .mock(2026, 9, 6)
        )

        // When
        let content = makeResolver().content(for: request, in: .mock(events: [birthday]))

        // Then
        #expect(content.display.rows.map(\.direction) == [.upcoming])
        #expect(content.display.rows.map(\.dateText) == ["Sep 5, 2027"])
    }

    @Test
    func timelineThenResolvesEveryEntryForItsOwnDate() {
        // Given
        let event = makeEvent("Trip", onDay: 6)
        let request = makeRequest(.event(event.id))

        // When
        let timeline = makeResolver().timeline(for: request, in: .mock(events: [event]))

        // Then
        #expect(
            timeline.map(\.date)
                == [.mock(2026, 9, 4)] + (5...10).map { .mock(2026, 9, $0, hour: 0) }
        )
        #expect(
            timeline.flatMap(\.display.rows).map(\.phrase)
                == [
                    DayCount(days: 2, direction: .upcoming),
                    DayCount(days: 1, direction: .upcoming),
                    DayCount(days: 0, direction: .today),
                    DayCount(days: 1, direction: .past),
                    DayCount(days: 2, direction: .past),
                    DayCount(days: 3, direction: .past),
                    DayCount(days: 4, direction: .past),
                ]
                .map(RelativeTimePhrase.init)
        )
    }

    @Test
    func timelineWhenAShownEventHasATimeThenAddsTheMomentsItsPhraseChanges() {
        // Given
        let meeting = CountdownEvent.mock(
            title: "Meeting",
            year: 2026,
            month: 9,
            day: 6,
            hour: 15,
            minute: 0,
            timeZone: .mockUTC,
            repeatRule: .yearly
        )
        let store = WidgetStoreContents.mock(events: [meeting, makeEvent("Trip", onDay: 8)])

        // When
        let all = makeResolver().timeline(for: makeRequest(.allEvents), in: store)
        let trip = makeResolver().timeline(
            for: makeRequest(.event(store.events[1].id)),
            in: store
        )

        // Then
        #expect(all.map(\.date).contains(.mock(2026, 9, 6, hour: 15).addingTimeInterval(1)))
        #expect(trip.count == 7)
    }

    @Test(
        arguments: [
            (WidgetContentSource.automaticFocus, WidgetFamily.systemSmall, false),
            (.allEvents, .systemSmall, false),
            (.automaticFocus, .systemMedium, false),
            (.event(nil), .systemLarge, false),
            (.allEvents, .systemMedium, true),
            (.category(nil), .systemLarge, true),
        ]
    )
    func placeholderThenShowsOneSampleEventLaidOutLikeTheRequest(
        source: WidgetContentSource,
        family: WidgetFamily,
        isList: Bool
    ) {
        // Given / When
        let content = makeResolver().placeholder(titled: "Sample", for: makeRequest(source, family))

        // Then
        #expect(content.date == .mock(2026, 9, 4))
        #expect(content.display.isList == isList)
        #expect(content.display.rows.map(\.title) == ["Sample"])
        #expect(
            content.display.rows.map(\.phrase) == [
                RelativeTimePhrase(DayCount(days: 12, direction: .upcoming))
            ]
        )
        #expect(content.display.rows.map(\.dateText) == ["Sep 16"])
        #expect(content.link == .collection(.all))
    }
}

private extension WidgetContentResolverTests {
    func makeResolver() -> WidgetContentResolver {
        WidgetContentResolver(timeZone: .mockUTC, locale: .mockAmericanEnglish)
    }

    func makeRequest(
        _ source: WidgetContentSource,
        _ family: WidgetFamily = .systemSmall
    ) -> WidgetContentRequest {
        WidgetContentRequest(source: source, family: family, now: .mock(2026, 9, 4))
    }

    func makeEvent(_ title: String, onDay day: Int, category: EventCategory? = nil)
        -> CountdownEvent
    {
        .mock(
            title: title,
            year: 2026,
            month: 9,
            day: day,
            timeZone: .mockUTC,
            category: category
        )
    }
}
