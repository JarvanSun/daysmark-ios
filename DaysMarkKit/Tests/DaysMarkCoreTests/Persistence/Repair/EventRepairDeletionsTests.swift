//
//  EventRepairDeletionsTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct EventRepairDeletionsTests {
    @Test
    func repairWhenADeletionArrivesBesideAnEditThenHidesTheEventAndKeepsBothRevisions() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent(in: context)
        let edit = revision(of: event, at: 10)
        let deletion = revision(of: event, at: 20, isDeletion: true)
        context.insert(edit)
        context.insert(deletion)
        event.currentRevisionID = edit.id
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        let unresolved = try EventRevisionWriter(context: context)
            .unresolvedRevisionIDs(eventID: event.id)
        #expect(event.deletedAt == deletion.createdAt)
        #expect(event.deletionRevisionID == deletion.id)
        #expect(event.currentRevisionID == edit.id)
        #expect(unresolved == [edit.id, deletion.id])
    }

    @Test
    func repairWhenADeletionRequestsPermanenceThenMarksTheEvent() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent(in: context)
        let deletion = revision(of: event, at: 20, isDeletion: true, isPermanent: true)
        context.insert(deletion)
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        #expect(event.deletedAt == deletion.createdAt)
        #expect(event.permanentDeletionRequestedAt == deletion.createdAt)
    }

    @Test
    func repairWhenARestoreNamesTheDeletionThenShowsTheEventAgain() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent(in: context)
        let deletion = revision(of: event, at: 20, isDeletion: true)
        context.insert(deletion)
        context.insert(revision(of: event, at: 30, restoring: deletion.id))
        event.deletedAt = deletion.createdAt
        event.deletionRevisionID = deletion.id
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        #expect(event.deletedAt == nil)
        #expect(event.deletionRevisionID == nil)
    }

    @Test
    func repairWhenAnOldRestoreArrivesAfterANewerDeletionThenKeepsTheEventDeleted() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent(in: context)
        let firstDeletion = revision(of: event, at: 20, isDeletion: true)
        let secondDeletion = revision(of: event, at: 40, isDeletion: true)
        context.insert(firstDeletion)
        context.insert(revision(of: event, at: 30, restoring: firstDeletion.id))
        context.insert(secondDeletion)
        event.deletedAt = firstDeletion.createdAt
        event.deletionRevisionID = firstDeletion.id
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        #expect(event.deletedAt == secondDeletion.createdAt)
        #expect(event.deletionRevisionID == secondDeletion.id)
    }

    @Test
    func repairWhenThePendingDeletionHasNotArrivedThenLeavesTheDeletionAlone() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent(in: context)
        let pendingDeletionID = UUID()
        let pendingDeletionDate = Date(timeIntervalSince1970: 50)
        context.insert(revision(of: event, at: 20, isDeletion: true))
        event.deletedAt = pendingDeletionDate
        event.deletionRevisionID = pendingDeletionID
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        #expect(event.deletedAt == pendingDeletionDate)
        #expect(event.deletionRevisionID == pendingDeletionID)
    }

    @Test
    func repairWhenTheRootRevisionIsDuplicatedThenKeepsOneRootAndTheDescendantPointer() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent(in: context)
        let duplicateRoot = EventRevision(
            id: event.id,
            eventID: event.id,
            parentRevisionID: nil,
            conflictGroupID: EventRevisionWriter(context: context).rootConflictGroupID,
            createdAt: .mockNow,
            event: event
        )
        let descendant = revision(of: event, at: 10)
        context.insert(duplicateRoot)
        context.insert(descendant)
        event.currentRevisionID = descendant.id
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)
        try context.save()

        // Then
        let roots = try context.fetch(FetchDescriptor<EventRevision>()).filter {
            $0.eventID == event.id && $0.parentRevisionID == nil
        }
        #expect(roots.count == 1)
        #expect(event.currentRevisionID == descendant.id)
    }
}

private extension EventRepairDeletionsTests {
    func storedEvent(in context: ModelContext) throws -> CountdownEvent {
        let event = CountdownEvent.mock()
        context.insert(event)
        EventRevisionWriter(context: context).appendInitialRevision(for: event, at: .mockNow)
        try context.save()

        return event
    }

    func revision(
        of event: CountdownEvent,
        at seconds: TimeInterval,
        isDeletion: Bool = false,
        isPermanent: Bool = false,
        restoring deletionID: UUID? = nil
    ) -> EventRevision {
        EventRevision(
            eventID: event.id,
            parentRevisionID: event.id,
            conflictGroupID: event.id,
            restoredDeletionRevisionID: deletionID,
            createdAt: Date(timeIntervalSince1970: seconds),
            isDeletion: isDeletion,
            isPermanentDeletionRequest: isPermanent,
            event: event
        )
    }
}
