//
//  CurrentTimeTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import EventsFeature

struct CurrentTimeTests {
    @Test func moveThenTakesTheGivenInstantAndTimeZone() throws {
        // Given
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let time = CurrentTime.mock()
        let later = Date.mockNow.addingTimeInterval(3_600)

        // When
        time.move(to: later, timeZone: berlin)

        // Then
        #expect(time.now == later)
        #expect(time.timeZone == berlin)
    }

    @Test func refreshThenMovesToTheCurrentInstant() {
        // Given
        let time = CurrentTime.mock()

        // When
        time.refresh()

        // Then
        #expect(time.now != .mockNow)
    }
}
