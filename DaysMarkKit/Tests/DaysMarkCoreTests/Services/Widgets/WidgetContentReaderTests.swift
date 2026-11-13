//
//  WidgetContentReaderTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing
import WidgetKit

@testable import DaysMarkCore

@MainActor
struct WidgetContentReaderTests {
    @Test
    func contentThenShowsWhatTheAppSaved() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let trip = makeEvent("Trip", onDay: 10)
        try insert([trip, makeEvent("Dentist", onDay: 20)], into: container)

        // When
        let content = await makeReader(container).content(for: makeRequest(.allEvents))

        // Then
        #expect(
            content
                == WidgetContent(
                    date: .mock(2026, 9, 4),
                    display: .event(
                        WidgetRow(
                            id: trip.id,
                            title: "Trip",
                            phrase: RelativeTimePhrase(DayCount(days: 6, direction: .upcoming)),
                            dateText: "Sep 10, 2026",
                            direction: .upcoming
                        )
                    ),
                    link: .event(trip.id)
                )
        )
    }

    @Test
    func contentWhenTheAppSetAFocusThenTheAutomaticFocusFollowsIt() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let later = makeEvent("Later", onDay: 20)
        try insert([makeEvent("Nearest", onDay: 5), later], into: container)
        try SwiftDataEventRepository.mock(in: container).setFocus(eventID: later.id)

        // When
        let content = await makeReader(container).content(for: makeRequest(.automaticFocus))

        // Then
        #expect(content.display.rows.map(\.id) == [later.id])
    }

    @Test
    func contentWhenAnEventIsInRecentlyDeletedThenLeavesItOut() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let trip = makeEvent("Trip", onDay: 10)
        try insert([trip], into: container)
        try SwiftDataEventRepository.mock(in: container).delete(eventID: trip.id)

        // When
        let content = await makeReader(container).content(for: makeRequest(.allEvents))

        // Then
        #expect(content.display == .unavailable(.noEvents))
    }

    @Test
    func contentWhenTheAppSavesBetweenTwoRequestsThenShowsTheNewEvent() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let opener = ModelContainerOpenerSpy(opening: container)
        let reader = makeReader(opener)
        let before = await reader.content(for: makeRequest(.allEvents))
        try insert([makeEvent("Trip", onDay: 10)], into: container)

        // When
        let after = await reader.content(for: makeRequest(.allEvents))

        // Then
        #expect(before.display == .unavailable(.noEvents))
        #expect(after.display.rows.map(\.title) == ["Trip"])
        #expect(opener.openCount == 1)
    }

    @Test
    func contentWhenTheStoreCannotBeOpenedThenIsUnavailableAndOpensItAgainNextTime() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try insert([makeEvent("Trip", onDay: 10)], into: container)
        let opener = ModelContainerOpenerSpy(opening: container, failingFirst: 1)
        let reader = makeReader(opener)

        // When
        let failed = await reader.content(for: makeRequest(.allEvents))
        let recovered = await reader.content(for: makeRequest(.allEvents))

        // Then
        #expect(failed.display == .unavailable(.noEvents))
        #expect(recovered.display.rows.map(\.title) == ["Trip"])
        #expect(opener.openCount == 2)
    }

    @Test
    func timelineThenCoversSevenDaysFromNow() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try insert([makeEvent("Trip", onDay: 10)], into: container)

        // When
        let timeline = await makeReader(container).timeline(for: makeRequest(.allEvents))

        // Then
        #expect(
            timeline.map(\.date)
                == [.mock(2026, 9, 4)] + (5...10).map { .mock(2026, 9, $0, hour: 0) }
        )
        #expect(
            timeline.last?.display.rows.map(\.phrase) == [
                RelativeTimePhrase(DayCount(days: 0, direction: .today))
            ]
        )
    }

    @Test
    func placeholderThenNeedsNoStore() {
        // Given
        let reader = makeReader(
            ModelContainerOpenerSpy(opening: .mockInMemory(), failingFirst: .max)
        )

        // When
        let content = reader.placeholder(titled: "Sample", for: makeRequest(.automaticFocus))

        // Then
        #expect(content.display.rows.map(\.title) == ["Sample"])
    }

    @Test
    func eventOptionsWithIDsThenKeepsTheAskedOrderAndSkipsUnknownEvents() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let trip = makeEvent("Trip", onDay: 10)
        let dentist = makeEvent("Dentist", onDay: 20)
        try insert([trip, dentist], into: container)

        // When
        let options = await makeReader(container).eventOptions(
            withIDs: [dentist.id, UUID(), trip.id]
        )

        // Then
        #expect(
            options == [
                WidgetEventOption(id: dentist.id, title: "Dentist"),
                WidgetEventOption(id: trip.id, title: "Trip"),
            ]
        )
    }

    @Test
    func suggestedEventOptionsThenOffersTheFirstFiftyInHomeOrder() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let events = (1...52).map { makeEvent("Event \($0)", onDay: 4, yearsAhead: 53 - $0) }
        try insert(events, into: container)

        // When
        let options = await makeReader(container).suggestedEventOptions(at: .mock(2026, 9, 4))

        // Then
        #expect(options.map(\.title) == (3...52).reversed().map { "Event \($0)" })
    }

    @Test
    func eventOptionsTitledThenMatchesTitlesIgnoringCaseInHomeOrder() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try insert(
            [
                makeEvent("Trip to Rome", onDay: 20),
                makeEvent("Dentist", onDay: 6),
                makeEvent("Road trip", onDay: 10),
            ],
            into: container
        )

        // When
        let options = await makeReader(container).eventOptions(
            titled: "TRIP",
            at: .mock(2026, 9, 4)
        )

        // Then
        #expect(options.map(\.title) == ["Road trip", "Trip to Rome"])
    }

    @Test
    func categoryOptionsThenListsTheCategoriesInTheirOrderWithoutDeletedOnes() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let travel = EventCategory(name: "Travel", icon: "airplane", sortOrder: 2)
        let family = EventCategory(name: "Family", icon: "heart", sortOrder: 1)
        let deleted = EventCategory(name: "Old", sortOrder: 0)
        deleted.deletedAt = .mockNow
        try insert([travel, family, deleted], into: container)

        // When
        let options = await makeReader(container).categoryOptions()

        // Then
        #expect(
            options == [
                WidgetCategoryOption(id: family.id, name: "Family", icon: "heart"),
                WidgetCategoryOption(id: travel.id, name: "Travel", icon: "airplane"),
            ]
        )
    }

    @Test
    func categoryOptionsWithIDsThenKeepsTheAskedOrderAndSkipsUnknownCategories() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let travel = EventCategory(name: "Travel", sortOrder: 2)
        let family = EventCategory(name: "Family", sortOrder: 1)
        try insert([travel, family], into: container)

        // When
        let options = await makeReader(container).categoryOptions(
            withIDs: [travel.id, UUID(), family.id]
        )

        // Then
        #expect(options.map(\.name) == ["Travel", "Family"])
    }
}

private extension WidgetContentReaderTests {
    func makeReader(_ container: ModelContainer) -> WidgetContentReader {
        makeReader(ModelContainerOpenerSpy(opening: container))
    }

    func makeReader(_ opener: ModelContainerOpenerSpy) -> WidgetContentReader {
        WidgetContentReader(
            timeZone: { .mockUTC },
            locale: { .mockAmericanEnglish },
            open: opener.open
        )
    }

    func makeRequest(_ source: WidgetContentSource) -> WidgetContentRequest {
        WidgetContentRequest(source: source, family: .systemSmall, now: .mock(2026, 9, 4))
    }

    func makeEvent(_ title: String, onDay day: Int, yearsAhead: Int = 0) -> CountdownEvent {
        .mock(
            title: title,
            year: 2026 + yearsAhead,
            month: 9,
            day: day,
            timeZone: .mockUTC,
            createdAt: .mockNow,
            updatedAt: .mockNow
        )
    }

    func insert(_ models: [any PersistentModel], into container: ModelContainer) throws {
        for model in models {
            container.mainContext.insert(model)
        }

        try container.mainContext.save()
    }
}
