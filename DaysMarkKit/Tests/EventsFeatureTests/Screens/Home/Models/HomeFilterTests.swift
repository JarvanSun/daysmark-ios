//
//  HomeFilterTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import DaysMarkCore
@testable import EventsFeature

struct HomeFilterTests {
    @Test(arguments: [("", ""), ("  \n", ""), ("  trip  ", "trip")])
    func queryThenIsTheTextWithoutSurroundingWhitespace(text: String, expected: String) {
        // Given / When
        let filter = HomeFilter(searchText: text)

        // Then
        #expect(filter.query == expected)
        #expect(filter.isSearching == !expected.isEmpty)
    }

    @Test(arguments: [
        ("munchen", true),
        ("TRIP", true),
        ("travel", true),
        ("zebra", false),
    ])
    func showsWhenSearchingThenMatchesTheTitleOrTheCategoryName(query: String, expected: Bool) {
        // Given
        let event = CountdownEvent.mock("München trip")
        let filter = HomeFilter(searchText: query)

        // When
        let shows = filter.shows(event, categoryName: "Travel")

        // Then
        #expect(shows == expected)
    }

    @Test func showsWhenSearchingThenIgnoresTheCategory() {
        // Given
        let event = CountdownEvent.mock("Trip")
        let filter = HomeFilter(categoryID: BuiltInCategory.birthday.id, searchText: "trip")

        // When
        let shows = filter.shows(event, categoryName: nil)

        // Then
        #expect(shows)
    }

    @Test(arguments: [
        (UUID?.none, true),
        (BuiltInCategory.important.id, true),
        (BuiltInCategory.birthday.id, false),
    ])
    func showsWithoutASearchThenKeepsTheEventsOfTheSelectedCategory(
        categoryID: UUID?,
        expected: Bool
    ) {
        // Given
        let event = CountdownEvent.mock()
        let filter = HomeFilter(categoryID: categoryID)

        // When
        let shows = filter.shows(event, categoryName: nil)

        // Then
        #expect(shows == expected)
    }
}
