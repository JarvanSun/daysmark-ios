//
//  WidgetStoreContentsTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct WidgetStoreContentsTests {
    @Test
    func eventsRelevantToThenKeepsWhatTheSourceCanShow() {
        // Given
        let travel = EventCategory(name: "Travel")
        let trip = CountdownEvent.mock(title: "Trip", category: travel)
        let dentist = CountdownEvent.mock(title: "Dentist")
        let contents = WidgetStoreContents.mock(events: [trip, dentist], categories: [travel])

        // Then
        #expect(contents.events(relevantTo: .automaticFocus).map(\.id) == [trip.id, dentist.id])
        #expect(contents.events(relevantTo: .allEvents).map(\.id) == [trip.id, dentist.id])
        #expect(contents.events(relevantTo: .event(dentist.id)).map(\.id) == [dentist.id])
        #expect(contents.events(relevantTo: .event(nil)).isEmpty)
        #expect(contents.events(relevantTo: .category(travel.id)).map(\.id) == [trip.id])
        #expect(contents.events(relevantTo: .category(nil)).isEmpty)
    }
}
