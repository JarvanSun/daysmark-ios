//
//  EventRepairTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct EventRepairTests {
    @Test
    func repairWhenAnEventIsDuplicatedThenKeepsOneRecordAndOneRootRevision() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let eventID = UUID()
        let first = duplicate(of: eventID, record: 1, titled: "First")
        let second = duplicate(of: eventID, record: 2, titled: "Second")
        context.insert(first)
        context.insert(second)
        EventRevisionWriter(context: context).appendInitialRevision(for: first, at: .mockNow)
        EventRevisionWriter(context: context).appendInitialRevision(for: second, at: .mockNow)
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
        let roots = try context.fetch(FetchDescriptor<EventRevision>()).filter {
            $0.eventID == eventID && $0.parentRevisionID == nil
        }
        #expect(events.count == 1)
        #expect(events.first?.recordID == first.recordID)
        #expect(roots.count == 1)
        #expect(events.first?.currentRevisionID == roots.first?.id)
    }

    @Test
    func repairWhenADeletionMarkerExistsThenHidesALateCopyOfTheEvent() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = CountdownEvent.mock(title: "Secret")
        context.insert(event)
        context.insert(PermanentDeletionMarker(eventID: event.id, deletedAt: .mockNow))
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        #expect(event.deletedAt == .mockNow)
        #expect(event.permanentDeletionRequestedAt == .mockNow)
    }

    @Test
    func repairWhenTheCategoryOfAnEventWasDeletedThenMovesItToImportantInANewRevision() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let travel = EventCategory(name: "Travel")
        travel.deletedAt = .mockNow
        context.insert(travel)
        let event = CountdownEvent.mock(title: "Trip", category: travel)
        context.insert(event)
        EventRevisionWriter(context: context).appendInitialRevision(for: event, at: .mockNow)
        try context.save()
        let rootID = event.currentRevisionID

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        #expect(event.categoryID == BuiltInCategory.important.id)
        #expect(event.category?.builtInKind == .important)
        #expect(event.currentRevisionID != rootID)
    }

    @Test
    func repairWhenTheCategoryHasNotArrivedThenKeepsTheCategoryIDAndShowsImportant() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let pendingCategoryID = UUID()
        let event = CountdownEvent.mock(title: "Trip")
        context.insert(event)
        EventRevisionWriter(context: context).appendInitialRevision(for: event, at: .mockNow)
        event.categoryID = pendingCategoryID
        try context.save()
        let rootID = event.currentRevisionID

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        #expect(event.categoryID == pendingCategoryID)
        #expect(event.category?.builtInKind == .important)
        #expect(event.currentRevisionID == rootID)
    }

    @Test
    func repairWhenTheFocusedEventWasDeletedThenClearsTheFocus() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let focus = FocusSelectionWriter(context: context)
        let event = CountdownEvent.mock(title: "Focus")
        context.insert(event)
        try context.save()
        try focus.select(event.id, at: .mockNow)
        event.deletedAt = .mockNow
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow.addingTimeInterval(60))

        // Then
        #expect(try focus.selectedEventID() == nil)
    }

    @Test
    func repairWhenTheCurrentRevisionHasNotArrivedThenLeavesThePointerAlone() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let event = CountdownEvent.mock(title: "Out of order")
        let missingRevisionID = UUID()
        event.currentRevisionID = missingRevisionID
        context.insert(event)
        try context.save()

        // When
        try EventRepair.mockSeeded(in: context).repair(now: .mockNow)

        // Then
        #expect(event.currentRevisionID == missingRevisionID)
        #expect(try context.fetch(FetchDescriptor<EventRevision>()).isEmpty)
    }
}

private extension EventRepairTests {
    func duplicate(of eventID: UUID, record number: UInt8, titled title: String) -> CountdownEvent {
        .mock(
            id: eventID,
            recordID: UUID(fixedGroup: 0, number: number),
            title: title,
            year: 2027,
            month: 1,
            day: 1,
            timeZone: .mockUTC
        )
    }
}
