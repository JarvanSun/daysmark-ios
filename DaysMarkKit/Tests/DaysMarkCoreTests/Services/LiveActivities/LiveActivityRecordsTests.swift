//
//  LiveActivityRecordsTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct LiveActivityRecordsTests {
    @Test func noteDismissalThenStoresTheDateUnderTheShippedKey() throws {
        // Given
        let defaults = try makeDefaults("dismissal")
        let records = LiveActivityRecords(defaults: defaults)
        let terminalDate = Date.mockNow.addingTimeInterval(900)

        // When
        records.noteDismissal(of: eventID, until: terminalDate)

        // Then
        #expect(
            defaults.object(
                forKey: "liveActivity.dismissedUntil.11111111-2222-4333-8444-555555555555"
            ) as? Date == terminalDate
        )
    }

    @Test func wasDismissedWhenNothingIsStoredThenIsFalse() throws {
        // Given
        let records = LiveActivityRecords(defaults: try makeDefaults("absent"))

        // When / Then
        #expect(!records.wasDismissed(eventID, now: .mockNow))
    }

    @Test func wasDismissedWhenTheDismissalStillHoldsThenIsTrue() throws {
        // Given
        let records = LiveActivityRecords(defaults: try makeDefaults("holding"))
        records.noteDismissal(of: eventID, until: Date.mockNow.addingTimeInterval(1))

        // When / Then
        #expect(records.wasDismissed(eventID, now: .mockNow))
    }

    @Test func wasDismissedWhenTheDismissalExpiredThenIsFalseAndForgetsIt() throws {
        // Given
        let defaults = try makeDefaults("expired")
        let records = LiveActivityRecords(defaults: defaults)
        records.noteDismissal(of: eventID, until: .mockNow)

        // When
        let wasDismissed = records.wasDismissed(eventID, now: .mockNow)

        // Then
        #expect(!wasDismissed)
        #expect(
            defaults.object(
                forKey: "liveActivity.dismissedUntil.11111111-2222-4333-8444-555555555555"
            ) == nil
        )
    }

    @Test func clearThenRemovesTheDismissal() throws {
        // Given
        let defaults = try makeDefaults("clear")
        let records = LiveActivityRecords(defaults: defaults)
        records.noteDismissal(of: eventID, until: .mockNow)

        // When
        records.clear(eventID)

        // Then
        #expect(
            defaults.dictionaryRepresentation().keys.allSatisfy { !$0.hasPrefix("liveActivity.") }
        )
    }

    private var eventID: UUID { UUID(uuidString: "11111111-2222-4333-8444-555555555555") ?? UUID() }

    private func makeDefaults(_ name: String) throws -> UserDefaults {
        let suite = "LiveActivityRecordsTests.\(name)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)

        return defaults
    }
}
