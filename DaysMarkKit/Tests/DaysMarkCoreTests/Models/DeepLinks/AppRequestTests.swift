//
//  AppRequestTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct AppRequestTests {
    private static let eventID = UUID(uuidString: "AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA")!

    @Test(arguments: [
        ("daysmark://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA", AppRequest.event(eventID)),
        ("daysmark://category/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA", .category(eventID)),
        ("daysmark://collection/all", .collection(.all)),
        ("daysmark://collection/birthdays", .collection(.birthdays)),
        ("daysmark://collection/anniversaries", .collection(.anniversaries)),
        ("daysmark://widgets", .widgets),
    ])
    func initWithURLThenReadsEveryForm(link: String, expected: AppRequest) throws {
        // Given
        let url = try #require(URL(string: link))

        // When
        let request = AppRequest(url: url)

        // Then
        #expect(request == expected)
    }

    @Test(arguments: [
        (AppRequest.event(eventID), "daysmark://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA"),
        (.category(eventID), "daysmark://category/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA"),
        (.collection(.all), "daysmark://collection/all"),
        (.collection(.birthdays), "daysmark://collection/birthdays"),
        (.collection(.anniversaries), "daysmark://collection/anniversaries"),
        (.widgets, "daysmark://widgets"),
    ])
    func urlThenWritesTheStoredForm(request: AppRequest, expected: String) {
        #expect(request.url?.absoluteString == expected)
    }

    @Test(arguments: [AppRequest.newEvent, .search])
    func urlForKeyboardCommandsThenIsMissing(request: AppRequest) {
        #expect(request.url == nil)
    }

    @Test(arguments: [
        "other://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA",
        "daysmark://event/not-a-uuid",
        "daysmark://event",
        "daysmark://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA/extra",
        "daysmark://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA?source=test",
        "daysmark://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA#top",
        "daysmark://collection/everything",
        "daysmark://collection/All",
        "daysmark://widgets/extra",
        "daysmark://settings",
    ])
    func initWithUnexpectedURLThenIsNotARequest(link: String) throws {
        // Given
        let url = try #require(URL(string: link))

        // Then
        #expect(AppRequest(url: url) == nil)
    }

    @Test(arguments: [
        "DAYSMARK://EVENT/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA",
        "daysmark://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA/",
        "daysmark://event/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
    ])
    func initWithEquivalentSpellingThenReadsTheEvent(link: String) throws {
        // Given
        let url = try #require(URL(string: link))

        // Then
        #expect(AppRequest(url: url) == .event(Self.eventID))
    }

    @Test(arguments: [
        (AppRequest.Collection.all, UUID?.none),
        (.birthdays, BuiltInCategory.birthday.id),
        (.anniversaries, BuiltInCategory.anniversary.id),
    ])
    func categoryIDThenNamesTheBuiltInCategory(collection: AppRequest.Collection, expected: UUID?) {
        #expect(collection.categoryID == expected)
    }
}
