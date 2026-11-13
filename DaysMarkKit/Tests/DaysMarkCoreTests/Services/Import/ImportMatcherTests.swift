//
//  ImportMatcherTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct ImportMatcherTests {
    @Test
    func resultWhenNothingMatchesThenCreates() throws {
        // Given
        let localSources = ModelContainer.mockLocalSources()
        var matcher = ImportMatcher(
            events: [],
            references: [],
            localContext: localSources.mainContext
        )

        // When
        let result = matcher.result(for: .mockContactBirthday)

        // Then
        #expect(result.decision == .create)
        #expect(result.eventID == nil)
        #expect(!matcher.hasChangedReferences)
    }

    @Test(arguments: [
        (ImportedDate.mockContactBirthday, false, false, ImportDecision.unchanged),
        (.mock(title: "Mary Birthday"), false, false, .change),
        (.mock(title: "Mary Birthday"), true, false, .conflict),
        (.mockContactBirthday, true, false, .unchanged),
        (.mock(title: "Mary Birthday"), false, true, .deleted),
    ])
    func resultWhenTheEventIsReferencedThenComparesTheSourceAndTheEvent(
        scanned: ImportedDate,
        isEdited: Bool,
        isDeleted: Bool,
        expected: ImportDecision
    ) throws {
        // Given
        let localSources = ModelContainer.mockLocalSources()
        let event = importedEvent(of: .mockContactBirthday)
        event.targetHour = isEdited ? 14 : nil
        event.deletedAt = isDeleted ? .mockNow : nil
        var matcher = ImportMatcher(
            events: [event],
            references: [reference(to: event, from: .mockContactBirthday)],
            localContext: localSources.mainContext
        )

        // When
        let result = matcher.result(for: scanned)

        // Then
        #expect(result.decision == expected)
        #expect(result.eventID == event.id)
    }

    @Test
    func resultWhenASyncedEventHasTheSameSourceThenAdoptsItOnThisDevice() throws {
        // Given
        let localSources = ModelContainer.mockLocalSources()
        let event = importedEvent(of: .mockContactBirthday)
        let onThisDevice = ImportedDate.mock(sourceIdentifier: "second-device-contact-id")
        var matcher = ImportMatcher(
            events: [event],
            references: [],
            localContext: localSources.mainContext
        )

        // When
        let result = matcher.result(for: onThisDevice)
        let again = matcher.result(for: .mock(sourceIdentifier: "duplicate-contact"))
        try localSources.mainContext.save()

        // Then
        let references = try localSources.mainContext.fetch(
            FetchDescriptor<LocalSourceReference>()
        )
        #expect(result.decision == .unchanged)
        #expect(result.eventID == event.id)
        #expect(again.decision == .create)
        #expect(matcher.hasChangedReferences)
        #expect(references.map(\.eventID) == [event.id])
        #expect(references.map(\.rawIdentifier) == ["second-device-contact-id"])
    }

    @Test
    func resultWhenTheReferencedEventIsGoneThenRemovesTheReferenceAndCreates() throws {
        // Given
        let localSources = ModelContainer.mockLocalSources()
        let orphaned = LocalSourceReference(
            eventID: UUID(),
            sourceKind: .contacts,
            rawIdentifier: ImportedDate.mockContactBirthday.sourceIdentifier
        )
        localSources.mainContext.insert(orphaned)
        try localSources.mainContext.save()
        var matcher = ImportMatcher(
            events: [],
            references: [orphaned],
            localContext: localSources.mainContext
        )

        // When
        let result = matcher.result(for: .mockContactBirthday)
        try localSources.mainContext.save()

        // Then
        #expect(result.decision == .create)
        #expect(matcher.hasChangedReferences)
        #expect(
            try localSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>()).isEmpty
        )
    }
}

private extension ImportMatcherTests {
    func importedEvent(of item: ImportedDate) -> CountdownEvent {
        let event = CountdownEvent(
            title: item.title,
            year: 2000,
            month: 4,
            day: 8,
            timeZone: item.timeZone,
            repeatRule: .yearly,
            createdAt: .mockNow,
            updatedAt: .mockNow
        )
        event.sourceKind = item.sourceKind
        event.snapshotDigest = ImportSourceDigest(item).rawValue
        event.conflictFingerprint = EventContentFingerprint(event).rawValue

        return event
    }

    func reference(to event: CountdownEvent, from item: ImportedDate) -> LocalSourceReference {
        LocalSourceReference(
            eventID: event.id,
            sourceKind: item.sourceKind,
            rawIdentifier: item.sourceIdentifier
        )
    }
}
