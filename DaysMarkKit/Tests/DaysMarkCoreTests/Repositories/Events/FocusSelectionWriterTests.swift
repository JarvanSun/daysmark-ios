//
//  FocusSelectionWriterTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct FocusSelectionWriterTests {
    @Test
    func selectWithoutAnyHistoryThenStartsInTheRootGroupWithTheFixedSelectionID() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent("Trip", in: context)

        // When
        try FocusSelectionWriter(context: context).select(event.id, at: .mockNow)

        // Then
        let selection = try #require(context.fetch(FetchDescriptor<FocusSelection>()).first)
        let revision = try #require(context.fetch(FetchDescriptor<FocusSelectionRevision>()).first)
        #expect(selection.id.uuidString == "F0C00000-0000-4000-8000-000000000004")
        #expect(selection.eventID == event.id)
        #expect(selection.updatedAt == .mockNow)
        #expect(revision.parentRevisionID == nil)
        #expect(revision.conflictGroupID.uuidString == "F0C00000-0000-4000-8000-000000000010")
        #expect(!context.hasChanges)
    }

    @Test
    func selectThenReplacesTheFocusAndNilRecordsAnEmptySelection() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let focus = FocusSelectionWriter(context: context)
        let first = try storedEvent("First", in: context)
        let second = try storedEvent("Second", in: context)

        // When
        try focus.select(first.id, at: .mockNow.addingTimeInterval(1))
        try focus.select(second.id, at: .mockNow.addingTimeInterval(2))
        let selectedSecond = try focus.selectedEventID()
        try focus.select(nil, at: .mockNow.addingTimeInterval(3))

        // Then
        let revisions = try context.fetch(FetchDescriptor<FocusSelectionRevision>())
        #expect(selectedSecond == second.id)
        #expect(try focus.selectedEventID() == nil)
        #expect(revisions.count == 3)
        #expect(revisions.contains { $0.eventID == nil && $0.parentRevisionID != nil })
    }

    @Test
    func selectWhenTheEventIsDeletedThenKeepsTheSelection() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = try storedEvent("Deleted", in: context)
        event.deletedAt = .mockNow
        try context.save()

        // When
        try FocusSelectionWriter(context: context).select(event.id, at: .mockNow)

        // Then
        #expect(try FocusSelectionWriter(context: context).selectedEventID() == nil)
        #expect(try context.fetch(FetchDescriptor<FocusSelectionRevision>()).isEmpty)
    }

    @Test
    func clearIfSelectingWhenAnotherEventIsFocusedThenKeepsTheFocus() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let focus = FocusSelectionWriter(context: context)
        let event = try storedEvent("Focus", in: context)
        try focus.select(event.id, at: .mockNow)

        // When
        try focus.clearIfSelecting(UUID(), at: .mockNow)

        // Then
        #expect(try focus.selectedEventID() == event.id)
    }

    @Test
    func repairWhenTheFocusedEventHasNotArrivedThenKeepsTheFocus() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let pendingID = try focusedEventThenRemoved(in: context)

        // When
        try FocusSelectionWriter(context: context).repair(now: Date(timeIntervalSince1970: 20))

        // Then
        #expect(try FocusSelectionWriter(context: context).selectedEventID() == pendingID)
    }

    @Test
    func repairWhenTheFocusedEventWasDeletedPermanentlyThenClearsTheFocus() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let deletedID = try focusedEventThenRemoved(in: context)
        context.insert(PermanentDeletionMarker(eventID: deletedID, deletedAt: .mockNow))
        try context.save()

        // When
        try FocusSelectionWriter(context: context).repair(now: Date(timeIntervalSince1970: 20))

        // Then
        #expect(try FocusSelectionWriter(context: context).selectedEventID() == nil)
    }

    @Test
    func repairWhenSelectionsAreDuplicatedThenKeepsTheRecordWithTheLowestRecordID() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let kept = FocusSelection.mock(recordID: UUID(fixedGroup: 0, number: 1), eventID: nil)
        let dropped = FocusSelection.mock(recordID: UUID(fixedGroup: 0, number: 2), eventID: nil)
        context.insert(dropped)
        context.insert(kept)
        try context.save()

        // When
        try FocusSelectionWriter(context: context).repair(now: .mockNow)

        // Then
        let selections = try context.fetch(FetchDescriptor<FocusSelection>())
        #expect(selections.map(\.recordID) == [kept.recordID])
    }
}

private extension FocusSelectionWriterTests {
    func storedEvent(_ title: String, in context: ModelContext) throws -> CountdownEvent {
        let event = CountdownEvent.mock(title: title)
        context.insert(event)
        try context.save()

        return event
    }

    func focusedEventThenRemoved(in context: ModelContext) throws -> UUID {
        let event = try storedEvent("Pending", in: context)
        let id = event.id
        try FocusSelectionWriter(context: context).select(id, at: Date(timeIntervalSince1970: 10))
        context.delete(event)
        try context.save()

        return id
    }
}
