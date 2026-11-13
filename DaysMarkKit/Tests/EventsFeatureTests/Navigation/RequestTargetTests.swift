//
//  RequestTargetTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore
@testable import EventsFeature

struct RequestTargetTests {
    @Test func initWithAVisibleEventThenTargetsDetail() {
        // Given
        let events = [CountdownEvent.mock(id: .mockActive)]

        // When
        let target = RequestTarget(.event(.mockActive), events: events, categories: [])

        // Then
        #expect(target == .detail(.mockActive))
    }

    @Test func initWithARecentlyDeletedEventThenTargetsRecovery() {
        // Given
        let events = [CountdownEvent.mockDeleted(id: .mockDeleted)]

        // When
        let target = RequestTarget(.event(.mockDeleted), events: events, categories: [])

        // Then
        #expect(target == .recentlyDeleted(.mockDeleted))
    }

    @Test func initWithAnUnknownEventThenHasNoTarget() {
        // Given
        let events = [CountdownEvent.mock(id: .mockActive)]

        // Then
        #expect(RequestTarget(.event(.mockMissing), events: events, categories: []) == nil)
    }

    @Test func initWithAPermanentlyDeletedEventThenHasNoTarget() {
        // Given
        let event = CountdownEvent.mockDeleted(id: .mockDeleted)
        event.permanentDeletionRequestedAt = .mockNow

        // Then
        #expect(RequestTarget(.event(.mockDeleted), events: [event], categories: []) == nil)
    }

    @Test(arguments: [
        (AppRequest.Collection.all, UUID?.none),
        (.birthdays, BuiltInCategory.birthday.id),
        (.anniversaries, BuiltInCategory.anniversary.id),
    ])
    func initWithACollectionThenTargetsHome(collection: AppRequest.Collection, categoryID: UUID?) {
        // Given / When
        let target = RequestTarget(.collection(collection), events: [], categories: [])

        // Then
        #expect(target == .home(categoryID: categoryID))
    }

    @Test func initWithAnExistingCategoryThenTargetsHome() {
        // Given
        let category = EventCategory(name: "Travel")

        // When
        let target = RequestTarget(.category(category.id), events: [], categories: [category])

        // Then
        #expect(target == .home(categoryID: category.id))
    }

    @Test func initWithADeletedCategoryThenTargetsTheWidgetInstructions() {
        // Given
        let category = EventCategory(name: "Travel")
        category.deletedAt = .mockNow

        // Then
        #expect(
            RequestTarget(.category(category.id), events: [], categories: [category]) == .widgets
        )
        #expect(RequestTarget(.category(UUID()), events: [], categories: []) == .widgets)
    }

    @Test(arguments: [
        (AppRequest.widgets, RequestTarget.widgets),
        (.newEvent, .newEvent),
        (.search, .search),
    ])
    func initWithARequestThatNeedsNoRecordThenKeepsIt(request: AppRequest, expected: RequestTarget)
    {
        #expect(RequestTarget(request, events: [], categories: []) == expected)
    }
}
