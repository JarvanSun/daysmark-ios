//
//  EventContentFingerprintTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct EventContentFingerprintTests {
    @Test
    func rawValueWhenTimedThenIsTheFingerprintStoredInSyncedEvents() {
        // Given
        let event = CountdownEvent.mock(
            title: " Launch Day ",
            year: 2031,
            month: 5,
            day: 4,
            hour: 14,
            minute: 5,
            timeZone: .mockTokyo,
            repeatRule: .yearly,
            calendarSystem: .gregorian,
            timeSemantics: .floatingLocalTime
        )
        event.categoryID = BuiltInCategory.birthday.id

        // When / Then
        #expect(
            EventContentFingerprint(event).rawValue
                == "a9c1c5d8920d3fb6eeb34c090d293c0828247cc8423e39134bdecdafc0b51b3f"
        )
    }

    @Test
    func rawValueWhenInALeapMonthThenIsTheFingerprintStoredInSyncedEvents() {
        // Given
        let event = CountdownEvent.mock(
            title: "Grandma’s Birthday",
            year: 18,
            month: 4,
            day: 3,
            timeZone: .mockUTC,
            repeatRule: .never,
            calendarSystem: .chinese
        )
        event.targetEra = 78
        event.targetIsLeapMonth = true

        // When / Then
        #expect(
            EventContentFingerprint(event).rawValue
                == "3f361ea42d1ddf370281d64a777fc1df28b4e077c52c146e53dfe7ddb591d6a5"
        )
    }

    @Test
    func rawValueWhenTheUserEditsTheEventThenChanges() {
        // Given
        let event = CountdownEvent.mock()
        let imported = EventContentFingerprint(event)

        // When
        event.targetHour = 14

        // Then
        #expect(EventContentFingerprint(event) != imported)
    }
}
