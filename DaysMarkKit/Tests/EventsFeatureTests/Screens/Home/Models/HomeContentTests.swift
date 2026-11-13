//
//  HomeContentTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore
@testable import EventsFeature

struct HomeContentTests {
    @Test func placeholderWithoutEventsThenIsNoEventsWhateverTheFilters() {
        // Given / When
        let content = HomeContent.mock(filter: .init(categoryID: BuiltInCategory.birthday.id))

        // Then
        #expect(content.placeholder == .noEvents)
        #expect(!content.hasEvents)
        #expect(!content.showsOverview)
    }

    @Test func placeholderWhenTheCategoryHidesEveryEventThenIsNoMatches() {
        // Given / When
        let content = HomeContent.mock(
            events: [.mock()],
            filter: .init(categoryID: BuiltInCategory.birthday.id)
        )

        // Then
        #expect(content.hasEvents)
        #expect(content.rows.isEmpty)
        #expect(content.placeholder == .noMatches)
        #expect(content.showsOverview)
    }

    @Test func placeholderWhenOnlyDeletedEventsExistThenIsNoEvents() {
        // Given / When
        let content = HomeContent.mock(events: [.mockDeleted()])

        // Then
        #expect(content.placeholder == .noEvents)
    }

    @Test func placeholderWhenSearchFindsNothingThenNamesTheTrimmedSearch() {
        // Given / When
        let content = HomeContent.mock(events: [.mock()], filter: .init(searchText: " zebra "))

        // Then
        #expect(content.placeholder == .noSearchResults("zebra"))
        #expect(!content.showsOverview)
    }

    @Test func placeholderWithEventsShownThenIsMissing() {
        // Given / When
        let content = HomeContent.mock(events: [.mock()])

        // Then
        #expect(content.placeholder == nil)
    }

    @Test func pinnedWithoutAChoiceThenIsTheNearestEventWithAStableTieBreak() {
        // Given
        let first = CountdownEvent.mock("Same", id: .mockActive)
        let second = CountdownEvent.mock("Same", id: .mockDeleted)

        // When
        let automatic = HomeContent.mock(events: [second, first])
        let chosen = HomeContent.mock(events: [second, first], pinnedEventID: second.id)

        // Then
        #expect(automatic.pinned?.id == first.id)
        #expect(automatic.rows.map(\.id) == [first.id, second.id])
        #expect(chosen.pinned?.id == second.id)
        #expect(chosen.rows.map(\.id) == [first.id, second.id])
    }

    @Test func pinnedAtEqualDistanceThenPrefersTheFuture() {
        // Given
        let past = CountdownEvent.mock("Past", day: 7)
        let future = CountdownEvent.mock("Future", day: 13)

        // When
        let content = HomeContent.mock(events: [past, future])

        // Then
        #expect(content.pinned?.id == future.id)
        #expect(content.rows.map(\.id) == [future.id, past.id])
    }

    @Test func pinnedThenMatchesTheWidgetsAutomaticFocus() {
        // Given
        let holiday = CountdownEvent.mock("Holiday", day: 7)
        let birthday = CountdownEvent.mock("Birthday", day: 28)

        // When
        let content = HomeContent.mock(events: [holiday, birthday])
        let widgetFocus = EventSorter().focus(
            in: [holiday, birthday],
            now: .mockNow,
            userTimeZone: .gmt,
            focusedEventID: nil
        )

        // Then
        #expect(content.pinned?.id == holiday.id)
        #expect(content.pinned?.id == widgetFocus?.id)
    }

    @Test func pinnedThenFollowsTheGivenTimeZone() throws {
        // Given
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let now = Date.mock(2030, 9, 10, hour: 23, minute: 30)
        let event = CountdownEvent.mock("Tomorrow or today", day: 11)

        // When
        let inUTC = HomeContent.mock(events: [event], time: .mock(now: now))
        let inTokyo = HomeContent.mock(events: [event], time: .mock(now: now, timeZone: tokyo))

        // Then
        #expect(inUTC.pinned?.event.counted.dayCount == .init(days: 1, direction: .upcoming))
        #expect(inTokyo.pinned?.event.counted.dayCount == .init(days: 0, direction: .today))
    }

    @Test func eventsWhenSearchingThenMatchTitlesWithoutCaseOrDiacritics() {
        // Given
        let birthday = EventCategory(builtIn: .birthday)
        let important = EventCategory(builtIn: .important)
        let munich = CountdownEvent.mock("MÜNCHEN", day: 11, category: birthday)
        let trip = CountdownEvent.mock("München trip", day: 12, category: important)

        // When
        let content = HomeContent.mock(
            events: [trip, munich],
            categories: [birthday, important],
            filter: .init(searchText: "munchen")
        )

        // Then
        #expect(content.rows.map(\.id) == [munich.id, trip.id])
    }

    @Test func eventsWhenSearchingThenMatchTheCategoryName() {
        // Given
        let travel = EventCategory(name: "Travel")
        let trip = CountdownEvent.mock("Lisbon", day: 11, category: travel)
        let other = CountdownEvent.mock("Dentist", day: 12)

        // When
        let content = HomeContent.mock(
            events: [trip, other],
            categories: [travel],
            filter: .init(searchText: "travel")
        )

        // Then
        #expect(content.rows.map(\.id) == [trip.id])
    }

    @Test func eventsThenKeepOneOrderForTheListThePinnedEventAndSearch() {
        // Given
        let near = CountdownEvent.mock("Near Event", day: 11)
        let past = CountdownEvent.mock("Past Event", day: 8)
        let pinned = CountdownEvent.mock("Pinned Event", day: 14)
        let events = [pinned, past, near]

        // When
        let listed = HomeContent.mock(events: events, pinnedEventID: pinned.id)
        let searched = HomeContent.mock(
            events: events,
            pinnedEventID: pinned.id,
            filter: .init(searchText: "event")
        )

        // Then
        #expect(listed.pinned?.id == pinned.id)
        #expect(listed.rows.map(\.id) == [near.id, pinned.id, past.id])
        #expect(searched.rows.map(\.id) == [near.id, pinned.id, past.id])
        #expect(searched.filter.isSearching)
    }

    @Test func eventsWhenSearchingThenIgnoreTheFilters() {
        // Given
        let birthday = EventCategory(builtIn: .birthday)
        let important = EventCategory(builtIn: .important)
        let mia = CountdownEvent.mock("Mia", day: 11, category: birthday)
        let trip = CountdownEvent.mock("Trip", day: 12, category: important)
        let categories = [birthday, important]

        // When
        let filtered = HomeContent.mock(
            events: [mia, trip],
            categories: categories,
            filter: .init(categoryID: birthday.id)
        )
        let searched = HomeContent.mock(
            events: [mia, trip],
            categories: categories,
            filter: .init(categoryID: birthday.id, searchText: "trip")
        )

        // Then
        #expect(filtered.selectableIDs == [mia.id])
        #expect(searched.selectableIDs == [trip.id])
    }

    @Test func eventsWhenFilteredThenKeepThePinnedEventTheHorizonAndTheNextChange() {
        // Given
        let birthday = EventCategory(builtIn: .birthday)
        let past = CountdownEvent.mock("Past birthday", day: 8, category: birthday)
        let older = CountdownEvent.mock("Older birthday", day: 1, category: birthday)
        let future = CountdownEvent.mock("Future birthday", day: 12, category: birthday)
        let other = CountdownEvent.mock("Other", day: 9)
        let events = [past, older, future, other]
        let content = { (filter: HomeFilter) in
            HomeContent.mock(
                events: events,
                categories: [birthday],
                pinnedEventID: past.id,
                filter: filter
            )
        }

        // When
        let baseline = content(.init())
        let filtered = content(.init(categoryID: birthday.id))

        // Then
        #expect(baseline.rows.contains { $0.id == other.id })
        #expect(filtered.rows.map(\.id) == [future.id, past.id, older.id])
        #expect(filtered.pinned?.id == baseline.pinned?.id)
        #expect(filtered.horizon == baseline.horizon)
        #expect(filtered.nextChange == baseline.nextChange)
    }

    @Test func nextChangeForAFixedMomentThenFallsJustAfterItAndTheEventRollsOver() {
        // Given
        let event = CountdownEvent.mockTimed(hour: 12, minute: 1, semantics: .fixedInstant)
        let target = Date.mock(2030, 9, 10, hour: 12, minute: 1)

        // When
        let before = HomeContent.mock(events: [event])
        let after = HomeContent.mock(
            events: [event],
            time: .mock(now: target.addingTimeInterval(2))
        )

        // Then
        #expect(before.nextChange == target.addingTimeInterval(1))
        #expect(before.pinned?.event.counted.occurrence.year == 2030)
        #expect(after.pinned?.event.counted.occurrence.year == 2031)
    }

    @Test func nextChangeForALocalTimeThenUsesTheGivenTimeZone() throws {
        // Given
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let event = CountdownEvent.mockTimed(hour: 12, minute: 1, semantics: .floatingLocalTime)
        let before = Date.mock(2030, 9, 10, hour: 12, in: berlin)
        let target = Date.mock(2030, 9, 10, hour: 12, minute: 1, in: berlin)

        // When
        let early = HomeContent.mock(
            events: [event],
            time: .mock(now: before, timeZone: berlin)
        )
        let late = HomeContent.mock(
            events: [event],
            time: .mock(now: target.addingTimeInterval(2), timeZone: berlin)
        )

        // Then
        #expect(early.nextChange == target.addingTimeInterval(1))
        #expect(early.rows.first?.event.counted.occurrence.year == 2030)
        #expect(late.rows.first?.event.counted.occurrence.year == 2031)
    }

    @Test func nextChangeForATimedRangeThenIsItsStartAndThenJustAfterItsEnd() {
        // Given
        let event = CountdownEvent.mockTimed(hour: 12, minute: 10, semantics: .fixedInstant)
        event.rangeDurationSeconds = 60 * 60
        let start = Date.mock(2030, 9, 10, hour: 12, minute: 10)

        // When
        let before = HomeContent.mock(events: [event])
        let during = HomeContent.mock(
            events: [event],
            time: .mock(now: start.addingTimeInterval(5 * 60))
        )

        // Then
        #expect(before.nextChange == start)
        #expect(during.nextChange == start.addingTimeInterval(60 * 60 + 1))
    }

    @Test func categoriesThenOfferAnEmptyCustomCategoryUntilItIsDeleted() {
        // Given
        let custom = EventCategory(name: "Empty custom")
        let past = CountdownEvent.mock("Past", day: 8)
        let filter = HomeFilter(categoryID: custom.id)

        // When
        let offered = HomeContent.mock(events: [past], categories: [custom])
        let selected = HomeContent.mock(events: [past], categories: [custom], filter: filter)
        custom.deletedAt = .mockNow
        let afterDeletion = HomeContent.mock(events: [past], categories: [custom], filter: filter)

        // Then
        #expect(offered.categories.contains { $0.id == custom.id })
        #expect(selected.filter.categoryID == custom.id)
        #expect(selected.rows.isEmpty)
        #expect(afterDeletion.filter.categoryID == nil)
        #expect(afterDeletion.categories.allSatisfy { $0.id != custom.id })
        #expect(afterDeletion.rows.map(\.id) == [past.id])
    }

    @Test func categoriesThenStartWithAllAndMarkTheSelection() {
        // Given / When
        let content = HomeContent.mock(
            events: [.mock()],
            filter: .init(categoryID: BuiltInCategory.birthday.id)
        )

        // Then
        #expect(content.categories.first == .init(id: nil, name: nil, isSelected: false))
        #expect(
            content.categories.filter(\.isSelected).map(\.id) == [BuiltInCategory.birthday.id]
        )
        #expect(content.categories.count == BuiltInCategory.allCases.count + 1)
    }

    @Test func newEventCategoryIDThenIsTheShownCategoryOrImportantDate() {
        // Given
        let filter = HomeFilter(categoryID: BuiltInCategory.birthday.id)

        // Then
        #expect(
            HomeContent.mock(events: [.mock()]).newEventCategoryID == BuiltInCategory.important.id
        )
        #expect(
            HomeContent.mock(events: [.mock()], filter: filter).newEventCategoryID
                == BuiltInCategory.birthday.id
        )
        #expect(
            HomeContent.mock(filter: filter).newEventCategoryID == BuiltInCategory.important.id
        )
    }

    @Test func pinActionThenUnpinsThePinnedEventAndPinsAnyOther() {
        // Given
        let pinned = CountdownEvent.mock("Pinned")
        let other = CountdownEvent.mock("Other")

        // When
        let content = HomeContent.mock(events: [pinned, other], pinnedEventID: pinned.id)

        // Then
        #expect(content.pinAction(for: pinned.id) == .unpin)
        #expect(content.pinAction(for: other.id) == .pin(other.id))
        #expect(content.pinAction(for: other.id).pinnedEventID == other.id)
        #expect(content.pinAction(for: pinned.id).pinnedEventID == nil)
    }

    @Test func pinActionWithoutAChoiceThenPinsEvenTheAutomaticFocus() {
        // Given
        let event = CountdownEvent.mock()

        // When
        let content = HomeContent.mock(events: [event])

        // Then
        #expect(content.pinned?.id == event.id)
        #expect(content.pinAction(for: event.id) == .pin(event.id))
    }

    @Test func selectableIDsThenHoldOnlyTheShownEvents() {
        // Given
        let event = CountdownEvent.mock()

        // When
        let content = HomeContent.mock(events: [event, .mockDeleted()])

        // Then
        #expect(content.selectableIDs == [event.id])
    }
}
