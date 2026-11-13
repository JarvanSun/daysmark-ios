//
//  ImportantDateEntityTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreSpotlight
import DaysMarkCore
import Foundation
import SwiftData
import Testing

@testable import DaysMark

struct ImportantDateEntityTests {
    @Test func initThenCarriesTheMatch() throws {
        // Given
        let match = try makeMatch()

        // When
        let entity = ImportantDateEntity(match)

        // Then
        #expect(entity.id == match.id)
        #expect(entity.title == "Trip")
        #expect(entity.date == match.date)
        #expect(entity.category == "Important Date")
    }

    @Test func attributeSetThenLinksToTheEventInTheShippedURLForm() throws {
        // Given
        let entity = ImportantDateEntity(try makeMatch())

        // When
        let link = entity.attributeSet.contentURL

        // Then
        #expect(link?.absoluteString == "daysmark://event/\(entity.id.uuidString)")
    }

    private func makeMatch() throws -> EventMatch {
        let container = try ModelContainer.mockInMemory()
        let lookup = EventLookup(
            container: container,
            now: { .mockNow },
            timeZone: { .gmt },
            locale: { Locale(identifier: "en_US") }
        )
        let candidate = try lookup.candidate(
            creating: EventCreationInput(
                title: "Trip",
                startDate: Date.mockNow.addingTimeInterval(86_400)
            )
        )
        let events = SwiftDataEventRepository.mock(in: container)
        let eventID = try events.save(candidate.draft, replacing: nil)

        return try #require(lookup.events(withIDs: [eventID]).first)
    }
}
