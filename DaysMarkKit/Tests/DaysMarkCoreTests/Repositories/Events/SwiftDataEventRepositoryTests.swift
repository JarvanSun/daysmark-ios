//
//  SwiftDataEventRepositoryTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct SwiftDataEventRepositoryTests {
    @Test
    func saveWhenNewThenStoresTheEventWithItsRootRevisionAndRefreshes() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: container, refresher: refresher)

        // When
        let eventID = try service.save(.mock("Original"), replacing: nil)

        // Then
        let events = try container.mainContext.fetch(FetchDescriptor<CountdownEvent>())
        let event = try #require(events.first)
        let revisions = try container.mainContext.fetch(FetchDescriptor<EventRevision>())
        #expect(event.id == eventID)
        #expect(event.title == "Original")
        #expect(event.createdAt == .mockNow)
        #expect(revisions.map(\.id) == [eventID])
        #expect(event.currentRevisionID == eventID)
        #expect(!container.mainContext.hasChanges)
        #expect(refresher.refreshCount == 1)
    }

    @Test
    func saveWhenReplacingThenAppendsAChildRevisionAndRefreshes() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: container, refresher: refresher)
        var draft = EventDraft.mock("Original")
        let event = try service.create(from: draft)
        let rootID = try #require(event.currentRevisionID)
        draft.title = "Edited"

        // When
        let savedID = try service.save(draft, replacing: event.id)

        // Then
        let revisions = try container.mainContext.fetch(FetchDescriptor<EventRevision>())
        let root = try #require(revisions.first { $0.id == rootID })
        let child = try #require(revisions.first { $0.id == event.currentRevisionID })
        #expect(savedID == event.id)
        #expect(revisions.count == 2)
        #expect(root.title == "Original")
        #expect(child.title == "Edited")
        #expect(child.parentRevisionID == root.id)
        #expect(refresher.refreshCount == 2)
    }

    @Test
    func saveWhenTheEventIsMissingThenThrowsEventUnavailableWithoutRefreshing() {
        // Given
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: .mockInMemory(), refresher: refresher)

        // When / Then
        #expect(throws: EventError.eventUnavailable) {
            try service.save(.mock("Trip"), replacing: UUID())
        }
        #expect(refresher.refreshCount == 0)
    }

    @Test
    func saveWhenTheStoreRejectsTheSaveThenRollsBackAndDoesNotRefresh() throws {
        // Given
        let store = try ReadOnlyStore(seededWith: [.mock(title: "Original")])
        let context = store.container.mainContext
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: store.container, refresher: refresher)
        let event = try #require(try context.fetch(FetchDescriptor<CountdownEvent>()).first)
        var draft = EventDraft.mock(of: event)
        draft.title = "Edited"

        // When / Then
        #expect(throws: EventError.storeFailure) {
            try service.save(draft, replacing: event.id)
        }
        #expect(!context.hasChanges)
        #expect(event.title == "Original")
        #expect(try context.fetch(FetchDescriptor<EventRevision>()).isEmpty)
        #expect(refresher.refreshCount == 0)
    }

    @Test
    func deleteThenMarksTheEventDeletedOnTheMainContextAndRefreshes() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: container, refresher: refresher)
        var draft = EventDraft.mock("Trip")
        draft.reminders = [ReminderDraft(daysBefore: 0), ReminderDraft(daysBefore: 7)]
        let event = try service.create(from: draft)

        // When
        try service.delete(eventID: event.id)

        // Then
        let context = container.mainContext
        #expect(try context.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
        #expect(try context.fetch(FetchDescriptor<ReminderRule>()).count == 2)
        #expect(event.deletedAt == .mockNow)
        #expect(event.deletionRevisionID != nil)
        #expect(event.currentRevisionID == event.deletionRevisionID)
        #expect(!context.hasChanges)
        #expect(refresher.refreshCount == 2)
    }

    @Test
    func deleteWhenTheEventIsFocusedThenClearsTheFocus() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = SwiftDataEventRepository.mock(in: container)
        let eventID = try service.save(.mock("Focus"), replacing: nil)
        try service.setFocus(eventID: eventID)

        // When
        try service.delete(eventID: eventID)

        // Then
        let focus = FocusSelectionWriter(context: container.mainContext)
        #expect(try focus.selectedEventID() == nil)
    }

    @Test
    func deleteWhenTheStoreRejectsTheSaveThenLeavesNothingPendingForTheNextEvent() throws {
        // Given
        let store = try ReadOnlyStore(
            seededWith: [.mock(title: "First"), .mock(title: "Second")]
        )
        let context = store.container.mainContext
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: store.container, refresher: refresher)
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
        #expect(events.count == 2)

        for event in events {
            // When / Then
            #expect(throws: EventError.storeFailure) { try service.delete(eventID: event.id) }
            #expect(!context.hasChanges)
            #expect(event.deletedAt == nil)
            #expect(event.currentRevisionID == nil)
            #expect(try context.fetch(FetchDescriptor<EventRevision>()).isEmpty)
        }

        let freshContext = ModelContext(store.container)
        #expect(
            try freshContext.fetch(FetchDescriptor<CountdownEvent>()).allSatisfy {
                $0.deletedAt == nil
            }
        )
        #expect(try freshContext.fetchCount(FetchDescriptor<EventRevision>()) == 0)
        #expect(refresher.refreshCount == 0)
    }

    @Test
    func deleteWhenTheEventIsMissingThenThrowsEventUnavailable() {
        // Given
        let service = SwiftDataEventRepository.mock(in: .mockInMemory())

        // When / Then
        #expect(throws: EventError.eventUnavailable) { try service.delete(eventID: UUID()) }
    }

    @Test
    func restoreThenBringsTheEventBackWithoutFocusingItAndRefreshes() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: container, refresher: refresher)
        let event = try service.create(from: .mock("Focus"))
        try service.setFocus(eventID: event.id)
        try service.delete(eventID: event.id)
        let deletionRevisionID = event.deletionRevisionID
        let refreshCount = refresher.refreshCount

        // When
        try service.restore(eventID: event.id)

        // Then
        let revisions = try container.mainContext.fetch(FetchDescriptor<EventRevision>())
        let restoration = try #require(revisions.first { $0.id == event.currentRevisionID })
        #expect(event.deletedAt == nil)
        #expect(event.deletionRevisionID == nil)
        #expect(restoration.restoredDeletionRevisionID == deletionRevisionID)
        #expect(try FocusSelectionWriter(context: container.mainContext).selectedEventID() == nil)
        #expect(refresher.refreshCount == refreshCount + 1)
    }

    @Test
    func permanentlyDeleteThenRequestsItOnTheMainContextCleansLocalSourcesAndRefreshes() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(
            in: container,
            localSources: localSources,
            refresher: refresher
        )
        let event = try service.create(from: .mock("Seeded"))
        localSources.mainContext.insert(
            LocalSourceReference(
                eventID: event.id,
                sourceKind: .calendar,
                rawIdentifier: "device-only"
            )
        )
        try localSources.mainContext.save()
        try service.delete(eventID: event.id)
        let refreshCount = refresher.refreshCount

        // When
        try service.permanentlyDelete(eventID: event.id)

        // Then
        let local = localSources.mainContext
        #expect(event.permanentDeletionRequestedAt == .mockNow)
        #expect(try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
        #expect(try local.fetch(FetchDescriptor<LocalSourceReference>()).isEmpty)
        #expect(try local.fetch(FetchDescriptor<LocalSourceCleanupRequest>()).isEmpty)
        #expect(!container.mainContext.hasChanges)
        #expect(refresher.refreshCount == refreshCount + 1)
    }

    @Test
    func permanentlyDeleteWhenTheEventIsNotDeletedThenThrowsEventUnavailable() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = SwiftDataEventRepository.mock(
            in: container,
            localSources: .mockLocalSources()
        )
        let event = try service.create(from: .mock("Active"))

        // When / Then
        #expect(throws: EventError.eventUnavailable) {
            try service.permanentlyDelete(eventID: event.id)
        }
        #expect(event.deletedAt == nil)
        #expect(event.permanentDeletionRequestedAt == nil)
    }

    @Test
    func permanentlyDeleteWithoutALocalSourceStoreThenThrowsLocalStoreUnavailable() throws {
        // Given
        let service = SwiftDataEventRepository.mock(in: .mockInMemory())
        let eventID = try service.save(.mock("Trip"), replacing: nil)
        try service.delete(eventID: eventID)

        // When / Then
        #expect(throws: EventError.localStoreUnavailable) {
            try service.permanentlyDelete(eventID: eventID)
        }
    }

    @Test
    func permanentlyDeleteWhenTheStoreRejectsTheSaveThenLeavesTheRequestUnset() throws {
        // Given
        let first = CountdownEvent.mock(title: "First")
        let second = CountdownEvent.mock(title: "Second")
        first.deletedAt = Date(timeIntervalSince1970: 100)
        second.deletedAt = Date(timeIntervalSince1970: 100)
        let store = try ReadOnlyStore(seededWith: [first, second])
        let context = store.container.mainContext
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(
            in: store.container,
            localSources: .mockLocalSources(),
            refresher: refresher
        )

        for event in try context.fetch(FetchDescriptor<CountdownEvent>()) {
            // When / Then
            #expect(throws: EventError.storeFailure) {
                try service.permanentlyDelete(eventID: event.id)
            }
            #expect(event.permanentDeletionRequestedAt == nil)
            #expect(event.currentRevisionID == nil)
        }

        let freshContext = ModelContext(store.container)
        #expect(
            try freshContext.fetch(FetchDescriptor<CountdownEvent>()).allSatisfy {
                $0.deletedAt != nil && $0.permanentDeletionRequestedAt == nil
            }
        )
        #expect(try freshContext.fetchCount(FetchDescriptor<EventRevision>()) == 0)
        #expect(refresher.refreshCount == 0)
    }

    @Test
    func setFocusThenSelectsTheEventAndRefreshes() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: container, refresher: refresher)
        let eventID = try service.save(.mock("Trip"), replacing: nil)

        // When
        try service.setFocus(eventID: eventID)

        // Then
        let focus = FocusSelectionWriter(context: container.mainContext)
        #expect(try focus.selectedEventID() == eventID)
        #expect(!container.mainContext.hasChanges)
        #expect(refresher.refreshCount == 2)
    }

    @Test
    func setFocusWhenNilThenClearsTheSelection() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = SwiftDataEventRepository.mock(in: container)
        let eventID = try service.save(.mock("Trip"), replacing: nil)
        try service.setFocus(eventID: eventID)

        // When
        try service.setFocus(eventID: nil)

        // Then
        #expect(try FocusSelectionWriter(context: container.mainContext).selectedEventID() == nil)
    }

    @Test
    func moveEventsThenStagesTheMoveAndItsRevisionForTheCallerToSave() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: container, refresher: refresher)
        let travel = EventCategory(name: "Travel", icon: "airplane", sortOrder: 4)
        context.insert(travel)
        var draft = EventDraft.mock("Trip")
        draft.categoryID = travel.id
        let movedID = try service.save(draft, replacing: nil)
        let keptID = try service.save(.mock("Kept"), replacing: nil)
        let refreshCount = refresher.refreshCount

        // When
        try service.moveEvents(from: travel.id, to: BuiltInCategory.important.id)

        // Then
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
        let moved = try #require(events.first { $0.id == movedID })
        let kept = try #require(events.first { $0.id == keptID })
        #expect(moved.categoryID == BuiltInCategory.important.id)
        #expect(moved.category?.id == BuiltInCategory.important.id)
        #expect(moved.currentRevisionID != movedID)
        #expect(kept.currentRevisionID == keptID)
        #expect(context.hasChanges)
        #expect(refresher.refreshCount == refreshCount)
    }

    @Test
    func moveEventsWhenTheReplacementIsMissingThenThrowsStoreFailure() {
        // Given
        let service = SwiftDataEventRepository.mock(in: .mockInMemory())

        // When / Then
        #expect(throws: EventError.storeFailure) {
            try service.moveEvents(from: UUID(), to: UUID())
        }
    }
}
