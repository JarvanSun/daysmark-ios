//
//  EventLifecycleTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct EventLifecycleTests {
    @Test
    func softDeleteThenAppendsADeletionRevision() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent("Photo event", in: context)
        let rootID = event.currentRevisionID

        // When
        try EventLifecycle(context: context).softDelete(event, at: .mockNow)

        // Then
        let revisions = try context.fetch(FetchDescriptor<EventRevision>())
        let deletion = try #require(revisions.first { $0.id == event.deletionRevisionID })
        #expect(event.deletedAt == .mockNow)
        #expect(event.currentRevisionID == deletion.id)
        #expect(deletion.isDeletion)
        #expect(deletion.parentRevisionID == rootID)
        #expect(!context.hasChanges)
    }

    @Test
    func softDeleteWhenTheEventIsFocusedThenClearsTheFocus() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let focus = FocusSelectionWriter(context: context)
        let event = try storedEvent("Focus", in: context)
        try focus.repair(now: .mockNow)
        try focus.select(event.id, at: .mockNow)

        // When
        try EventLifecycle(context: context).softDelete(event, at: .mockNow)

        // Then
        #expect(try focus.selectedEventID() == nil)
    }

    @Test
    func restoreThenClearsTheDeletion() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let lifecycle = EventLifecycle(context: context)
        let event = try storedEvent("Photo event", in: context)
        try lifecycle.softDelete(event, at: .mockNow)

        // When
        try lifecycle.restore(event, at: .mockNow.addingTimeInterval(60))

        // Then
        #expect(event.deletedAt == nil)
        #expect(event.deletionRevisionID == nil)
    }

    @Test
    func restoreThenDoesNotFocusTheEventAgain() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let lifecycle = EventLifecycle(context: context)
        let focus = FocusSelectionWriter(context: context)
        let event = try storedEvent("Focus", in: context)
        try focus.repair(now: .mockNow)
        try focus.select(event.id, at: .mockNow)
        try lifecycle.softDelete(event, at: .mockNow)

        // When
        try lifecycle.restore(event, at: .mockNow)

        // Then
        #expect(try focus.selectedEventID() == nil)
    }

    @Test
    func requestPermanentDeletionThenMarksTheEventAndCleansItsLocalSources() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let context = container.mainContext
        let lifecycle = EventLifecycle(context: context)
        let event = try storedEvent("Document", in: context)
        localSources.mainContext.insert(
            LocalSourceReference(
                eventID: event.id,
                sourceKind: .calendar,
                rawIdentifier: "device-only"
            )
        )
        try localSources.mainContext.save()

        // When
        try lifecycle.requestPermanentDeletion(
            event,
            cleaningUp: LocalSourceCleanup(context: localSources.mainContext),
            at: .mockNow
        )

        // Then
        let local = localSources.mainContext
        #expect(event.deletedAt == .mockNow)
        #expect(event.permanentDeletionRequestedAt == .mockNow)
        #expect(try context.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
        #expect(try local.fetch(FetchDescriptor<LocalSourceReference>()).isEmpty)
        #expect(try local.fetch(FetchDescriptor<LocalSourceCleanupRequest>()).isEmpty)
    }

    @Test
    func purgeExpiredThenRemovesTheRecordsAndKeepsAMarkerThatBlocksItsSeed() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let context = container.mainContext
        let lifecycle = EventLifecycle(context: context)
        let cleanup = LocalSourceCleanup(context: localSources.mainContext)
        let event = try storedEvent("Seeded", in: context)
        let eventID = event.id
        event.seedIdentifier = "onboarding.new-year"
        try lifecycle.softDelete(event, at: .mockNow)
        try lifecycle.requestPermanentDeletion(event, cleaningUp: cleanup, at: .mockNow)
        let purgeDate = Date.mockNow.addingTimeInterval(lifecycle.retention + 1)

        // When
        let purged = try lifecycle.purgeExpired(cleaningUp: cleanup, now: purgeDate)

        // Then
        let local = localSources.mainContext
        let marker = try #require(
            try context.fetch(FetchDescriptor<PermanentDeletionMarker>()).first
        )
        #expect(purged == 1)
        #expect(try context.fetch(FetchDescriptor<CountdownEvent>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<EventRevision>()).isEmpty)
        #expect(marker.eventID == eventID)
        #expect(marker.seedIdentifier == "onboarding.new-year")
        #expect(marker.deletedAt == purgeDate)
        #expect(try local.fetch(FetchDescriptor<LocalSourceReference>()).isEmpty)
        #expect(try local.fetch(FetchDescriptor<LocalSourceCleanupRequest>()).isEmpty)
    }

    @Test
    func purgeExpiredWhenTheRetentionHasNotPassedThenKeepsTheEvent() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let lifecycle = EventLifecycle(context: context)
        let cleanup = LocalSourceCleanup(context: ModelContainer.mockLocalSources().mainContext)
        let event = try storedEvent("Recent", in: context)
        try lifecycle.softDelete(event, at: .mockNow)

        // When
        let purged = try lifecycle.purgeExpired(
            cleaningUp: cleanup,
            now: .mockNow.addingTimeInterval(lifecycle.retention - 1)
        )

        // Then
        #expect(purged == 0)
        #expect(try context.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
    }

    @Test
    func purgeExpiredWhenAConflictIsOpenThenKeepsTheEvent() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let context = container.mainContext
        let lifecycle = EventLifecycle(context: context)
        let cleanup = LocalSourceCleanup(context: localSources.mainContext)
        let event = try storedEvent("Conflict", in: context)
        let rootID = try #require(event.currentRevisionID)

        for _ in 0..<2 {
            context.insert(
                EventRevision(
                    eventID: event.id,
                    parentRevisionID: rootID,
                    conflictGroupID: rootID,
                    createdAt: .mockNow,
                    event: event
                )
            )
        }

        try context.save()
        try lifecycle.requestPermanentDeletion(event, cleaningUp: cleanup, at: .mockNow)
        #expect(event.permanentDeletionRequestedAt != nil)

        // When
        let purged = try lifecycle.purgeExpired(
            cleaningUp: cleanup,
            now: .mockNow.addingTimeInterval(lifecycle.retention + 1)
        )

        // Then
        #expect(purged == 0)
        #expect(try context.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
    }
}

private extension EventLifecycleTests {
    func storedEvent(_ title: String, in context: ModelContext) throws -> CountdownEvent {
        let event = CountdownEvent.mock(title: title)
        context.insert(event)
        EventRevisionWriter(context: context).appendInitialRevision(for: event, at: .mockNow)
        try context.save()

        return event
    }
}
