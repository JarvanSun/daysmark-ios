//
//  LocalSourceCleanupTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct LocalSourceCleanupTests {
    @Test
    func requestWhenRepeatedThenKeepsOneRequestForTheEvent() throws {
        // Given
        let localSources = ModelContainer.mockLocalSources()
        let cleanup = LocalSourceCleanup(context: localSources.mainContext)
        let eventID = UUID()

        // When
        try cleanup.request(for: eventID, at: .mockNow)
        try cleanup.request(for: eventID, at: .mockNow)

        // Then
        let requests = try localSources.mainContext.fetch(
            FetchDescriptor<LocalSourceCleanupRequest>()
        )
        #expect(requests.map(\.eventID) == [eventID])
        #expect(requests.map(\.requestedAt) == [.mockNow])
    }

    @Test
    func finishThenRemovesTheReferencesAndTheRequestOfTheEventOnly() throws {
        // Given
        let localSources = ModelContainer.mockLocalSources()
        let context = localSources.mainContext
        let cleanup = LocalSourceCleanup(context: context)
        let eventID = UUID()
        let otherID = UUID()

        for id in [eventID, otherID] {
            context.insert(
                LocalSourceReference(eventID: id, sourceKind: .contacts, rawIdentifier: "raw")
            )
            try cleanup.request(for: id, at: .mockNow)
        }

        // When
        try cleanup.finish(for: eventID)

        // Then
        #expect(
            try context.fetch(FetchDescriptor<LocalSourceReference>()).map(\.eventID) == [otherID]
        )
        #expect(
            try context.fetch(FetchDescriptor<LocalSourceCleanupRequest>()).map(\.eventID)
                == [otherID]
        )
    }

    @Test
    func finishInterruptedWhenAnEventWasDeletedPermanentlyElsewhereThenCleansItsReferences() throws
    {
        // Given
        let synced = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let event = CountdownEvent.mock(title: "Remote deletion")
        event.deletedAt = Date(timeIntervalSince1970: 10)
        event.permanentDeletionRequestedAt = Date(timeIntervalSince1970: 20)
        synced.mainContext.insert(event)
        localSources.mainContext.insert(
            LocalSourceReference(
                eventID: event.id,
                sourceKind: .contacts,
                rawIdentifier: "device-private"
            )
        )
        try synced.mainContext.save()
        try localSources.mainContext.save()

        // When
        try LocalSourceCleanup(context: localSources.mainContext)
            .finishInterrupted(comparingWith: synced.mainContext)

        // Then
        #expect(
            try localSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>()).isEmpty
        )
    }

    @Test
    func finishInterruptedWhenARequestOutlivedItsEventThenCleansItsReferences() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let removedEventID = UUID()
        localSources.mainContext.insert(
            LocalSourceCleanupRequest(eventID: removedEventID, requestedAt: .mockNow)
        )
        localSources.mainContext.insert(
            LocalSourceReference(
                eventID: removedEventID,
                sourceKind: .calendar,
                rawIdentifier: "device-private"
            )
        )
        try localSources.mainContext.save()

        // When
        try LocalSourceCleanup(context: localSources.mainContext)
            .finishInterrupted(comparingWith: synced.mainContext)

        // Then
        let local = localSources.mainContext
        #expect(try local.fetch(FetchDescriptor<LocalSourceReference>()).isEmpty)
        #expect(try local.fetch(FetchDescriptor<LocalSourceCleanupRequest>()).isEmpty)
    }

    @Test
    func finishInterruptedWhenTheEventStillExistsThenKeepsItsReferences() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let event = CountdownEvent.mock(title: "Active")
        synced.mainContext.insert(event)
        localSources.mainContext.insert(
            LocalSourceReference(eventID: event.id, sourceKind: .contacts, rawIdentifier: "raw")
        )
        try synced.mainContext.save()
        try localSources.mainContext.save()

        // When
        try LocalSourceCleanup(context: localSources.mainContext)
            .finishInterrupted(comparingWith: synced.mainContext)

        // Then
        #expect(
            try localSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>()).count == 1
        )
    }
}
