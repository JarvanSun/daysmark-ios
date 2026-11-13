//
//  EventRevisionWriterTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct EventRevisionWriterTests {
    @Test
    func appendInitialRevisionThenStartsTheHistoryInTheRootGroup() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let event = CountdownEvent.mock()
        container.mainContext.insert(event)

        // When
        EventRevisionWriter(context: container.mainContext)
            .appendInitialRevision(for: event, at: .mockNow)

        // Then
        let revisions = try container.mainContext.fetch(FetchDescriptor<EventRevision>())
        let root = try #require(revisions.first)
        #expect(revisions.count == 1)
        #expect(root.id == event.id)
        #expect(root.parentRevisionID == nil)
        #expect(root.conflictGroupID.uuidString == "00000000-0000-4000-8000-000000000010")
        #expect(root.createdAt == .mockNow)
        #expect(event.currentRevisionID == root.id)
    }

    @Test
    func appendInitialRevisionWhenTheEventHasARevisionThenAddsNothing() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let writer = EventRevisionWriter(context: container.mainContext)
        let event = CountdownEvent.mock()
        container.mainContext.insert(event)
        writer.appendInitialRevision(for: event, at: .mockNow)

        // When
        writer.appendInitialRevision(for: event, at: .mockNow)

        // Then
        #expect(try container.mainContext.fetch(FetchDescriptor<EventRevision>()).count == 1)
    }

    @Test
    func appendContentRevisionThenContinuesFromTheCurrentRevision() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let writer = EventRevisionWriter(context: container.mainContext)
        let event = CountdownEvent.mock()
        container.mainContext.insert(event)
        writer.appendInitialRevision(for: event, at: .mockNow)
        let rootID = try #require(event.currentRevisionID)

        // When
        writer.appendContentRevision(for: event, at: .mockNow, superseding: [rootID])

        // Then
        let revisions = try container.mainContext.fetch(FetchDescriptor<EventRevision>())
        let child = try #require(revisions.first { $0.id == event.currentRevisionID })
        #expect(child.id != rootID)
        #expect(child.parentRevisionID == rootID)
        #expect(child.conflictGroupID == rootID)
        #expect(child.supersededRevisionIDs == [rootID])
    }

    @Test
    func unresolvedRevisionIDsWhenTwoRevisionsShareAParentThenNamesBoth() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let writer = EventRevisionWriter(context: container.mainContext)
        let (event, siblings) = try eventWithSiblingRevisions(in: container.mainContext)

        // When
        let unresolved = try writer.unresolvedRevisionIDs(eventID: event.id)

        // Then
        #expect(unresolved == Set(siblings))
    }

    @Test
    func unresolvedRevisionIDsWhenAResolutionSupersedesTheSiblingsThenIsEmpty() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let writer = EventRevisionWriter(context: container.mainContext)
        let (event, siblings) = try eventWithSiblingRevisions(in: container.mainContext)
        writer.appendContentRevision(for: event, at: .mockNow, superseding: siblings)

        // When
        let unresolved = try writer.unresolvedRevisionIDs(eventID: event.id)

        // Then
        #expect(unresolved.isEmpty)
    }

    @Test
    func unresolvedRevisionIDsWhenASiblingArrivesAfterTheResolutionThenNamesIt() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let writer = EventRevisionWriter(context: container.mainContext)
        let (event, siblings) = try eventWithSiblingRevisions(in: container.mainContext)
        let rootID = event.id
        writer.appendContentRevision(for: event, at: .mockNow, superseding: siblings)
        let late = EventRevision(
            eventID: event.id,
            parentRevisionID: rootID,
            conflictGroupID: rootID,
            createdAt: .mockNow,
            event: event
        )
        container.mainContext.insert(late)

        // When
        let unresolved = try writer.unresolvedRevisionIDs(eventID: event.id)

        // Then
        #expect(unresolved == [late.id])
    }

    @Test(arguments: [2, 1])
    func unresolvedRevisionIDsWhenTwoDevicesResolveOverlappingSiblingsThenNamesBothResolutions(
        supersededByTheSecond: Int
    ) throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let (event, siblings) = try eventWithSiblingRevisions(in: context)
        let first = resolution(of: event, after: siblings[0], superseding: siblings)
        let second = resolution(
            of: event,
            after: siblings[1],
            superseding: Array(siblings.suffix(supersededByTheSecond))
        )
        context.insert(first)
        context.insert(second)

        // When
        let unresolved = try EventRevisionWriter(context: context)
            .unresolvedRevisionIDs(eventID: event.id)

        // Then
        #expect(unresolved.isSuperset(of: [first.id, second.id]))
    }
}

private extension EventRevisionWriterTests {
    func resolution(
        of event: CountdownEvent,
        after parentID: UUID,
        superseding supersededIDs: [UUID]
    ) -> EventRevision {
        EventRevision(
            eventID: event.id,
            parentRevisionID: parentID,
            conflictGroupID: parentID,
            supersededRevisionIDs: supersededIDs,
            createdAt: .mockNow,
            event: event
        )
    }

    func eventWithSiblingRevisions(
        in context: ModelContext
    ) throws -> (event: CountdownEvent, siblings: [UUID]) {
        let event = CountdownEvent.mock(title: "Root")
        context.insert(event)
        EventRevisionWriter(context: context).appendInitialRevision(for: event, at: .mockNow)
        let rootID = try #require(event.currentRevisionID)
        let siblings = ["Device A", "Device B"].map { title in
            event.title = title

            return EventRevision(
                eventID: event.id,
                parentRevisionID: rootID,
                conflictGroupID: rootID,
                createdAt: .mockNow,
                event: event
            )
        }

        for sibling in siblings {
            context.insert(sibling)
            event.currentRevisionID = sibling.id
        }

        try context.save()

        return (event, siblings.map(\.id))
    }
}
