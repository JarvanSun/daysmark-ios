//
//  EventLookupTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct EventLookupTests {
    @Test
    func eventsWithIDsThenReturnsTheWantedEventsWithTheirNextOccurrenceAndCategory() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let family = EventCategory(name: "Family")
        let wanted = makeEvent("Reunion", onDay: 18, category: family)
        try insert([family, wanted, makeEvent("Dentist", onDay: 20)], into: container)

        // When
        let matches = EventLookup.mock(in: container).events(withIDs: [wanted.id, UUID()])

        // Then
        #expect(
            matches == [
                EventMatch(
                    id: wanted.id,
                    title: "Reunion",
                    date: .mock(2027, 1, 18, hour: 0),
                    categoryName: "Family"
                )
            ]
        )
    }

    @Test
    func eventsWithIDsWhenTheCategoryIsUnknownThenNamesItImportantDate() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let event = makeEvent("Reunion", onDay: 18)
        try insert([event], into: container)

        // When
        let matches = EventLookup.mock(in: container).events(withIDs: [event.id])

        // Then
        #expect(matches.map(\.categoryName) == ["Important Date"])
    }

    @Test
    func eventsWithIDsWhenTheEventIsInRecentlyDeletedThenLeavesItOut() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let event = makeEvent("Reunion", onDay: 18)
        try insert([event], into: container)
        try SwiftDataEventRepository.mock(in: container).delete(eventID: event.id)

        // When
        let matches = EventLookup.mock(in: container).events(withIDs: [event.id])

        // Then
        #expect(matches.isEmpty)
    }

    @Test
    func eventsTitledWhenSeveralTitlesContainTheTextThenReturnsEveryCandidate() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let events = [
            makeEvent("Mia’s Birthday", onDay: 18),
            makeEvent("Noah’s birthday", onDay: 20),
            makeEvent("Dentist", onDay: 22),
        ]
        try insert(events, into: container)

        // When
        let matches = EventLookup.mock(in: container).events(titled: "BIRTHDAY")

        // Then
        #expect(Set(matches.map(\.title)) == ["Mia’s Birthday", "Noah’s birthday"])
    }

    @Test
    func eventsTitledWhenNoTitleContainsTheTextThenReturnsNothing() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try insert([makeEvent("Dentist", onDay: 22)], into: container)

        // When
        let matches = EventLookup.mock(in: container).events(titled: "Birthday")

        // Then
        #expect(matches.isEmpty)
    }

    @Test
    func nearestEventsThenReturnsAtMostThreeInHomeOrder() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let events = [
            makeEvent("Fourth", onDay: 30),
            makeEvent("Second", onDay: 17),
            makeEvent("Past", onDay: 10),
            makeEvent("Third", onDay: 20),
            makeEvent("Today", onDay: 15),
        ]
        try insert(events, into: container)

        // When
        let matches = EventLookup.mock(in: container).nearestEvents(limit: 9, in: nil)

        // Then
        #expect(matches.map(\.title) == ["Today", "Second", "Third"])
    }

    @Test(arguments: [(0, 1), (-4, 1), (2, 2)])
    func nearestEventsWhenALimitIsGivenThenKeepsItBetweenOneAndThree(
        limit: Int,
        count: Int
    ) throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try insert((16...19).map { makeEvent("Day \($0)", onDay: $0) }, into: container)

        // When
        let matches = EventLookup.mock(in: container).nearestEvents(limit: limit, in: nil)

        // Then
        #expect(matches.count == count)
    }

    @Test
    func nearestEventsWhenACategoryIsGivenThenKeepsOnlyItsEvents() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let family = EventCategory(name: "Family")
        let events = [
            makeEvent("Reunion", onDay: 20, category: family), makeEvent("Dentist", onDay: 16),
        ]
        try insert([family] + events, into: container)

        // When
        let matches = EventLookup.mock(in: container).nearestEvents(limit: 3, in: family.id)

        // Then
        #expect(matches.map(\.title) == ["Reunion"])
    }

    @Test
    func distancePhraseThenIsTheRelativeTimePhraseOfTheEvent() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let event = makeEvent("Reunion", onDay: 18)
        try insert([event], into: container)
        let counted = try #require(
            EventSorter().counted([event], now: .mockNow, userTimeZone: .mockUTC).first
        )

        // When
        let phrase = EventLookup.mock(in: container).distancePhrase(for: event.id)

        // Then
        #expect(phrase == "in 3 days")
        #expect(
            phrase
                == counted.relativeTimePhrase(
                    at: .mockNow,
                    userTimeZone: .mockUTC,
                    locale: .mockAmericanEnglish
                ).text
        )
    }

    @Test
    func distancePhraseWhenTheEventIsUnknownThenIsNil() {
        // Given / When
        let phrase = EventLookup.mock(in: .mockInMemory()).distancePhrase(for: UUID())

        // Then
        #expect(phrase == nil)
    }

    @Test
    func categoriesThenListsEveryVisibleCategoryByItsDisplayName() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try SwiftDataCategoryRepository.mock(in: container).seedBuiltInCategories()
        let family = EventCategory(name: "Family")
        let deleted = EventCategory(name: "Gone")
        deleted.deletedAt = .mockNow
        try insert([family, deleted], into: container)

        // When
        let categories = EventLookup.mock(in: container).categories()

        // Then
        #expect(
            Set(categories.map(\.name)) == ["Important Date", "Birthday", "Anniversary", "Family"]
        )
        #expect(categories.first { $0.name == "Family" }?.id == family.id)
    }

    @Test
    func categoriesWithIDsThenReturnsOnlyTheWantedCategories() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let family = EventCategory(name: "Family")
        try insert([family, EventCategory(name: "Work")], into: container)

        // When
        let categories = EventLookup.mock(in: container).categories(withIDs: [family.id])

        // Then
        #expect(categories == [CategoryMatch(id: family.id, name: "Family")])
    }

    @Test
    func categoriesNamedWhenSeveralNamesContainTheTextThenReturnsEveryCandidate() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let categories = ["Family", "Family trips", "Work"].map { EventCategory(name: $0) }
        try insert(categories, into: container)

        // When
        let matches = EventLookup.mock(in: container).categories(named: "family")

        // Then
        #expect(Set(matches.map(\.name)) == ["Family", "Family trips"])
    }
}

private extension EventLookupTests {
    func makeEvent(
        _ title: String,
        onDay day: Int,
        category: EventCategory? = nil
    ) -> CountdownEvent {
        .mock(
            title: title,
            year: 2027,
            month: 1,
            day: day,
            timeZone: .mockUTC,
            category: category,
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
