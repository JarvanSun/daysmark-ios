//
//  ImportedEventWriterTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct SwiftDataEventRepositoryImportsTests {
    @Test
    func writeWhenCreatingThenStoresTheImportedEventWithItsProvenanceAndRootRevision() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try SwiftDataCategoryRepository.mock(in: container).seedBuiltInCategories()
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: container, refresher: refresher)
        let eventID = UUID()

        // When
        try service.write([
            .create(id: eventID, .mockContactBirthday, category: .birthday, reminder: nil)
        ])

        // Then
        let event = try #require(
            try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        #expect(event.id == eventID)
        #expect(event.title == "  Mary’s Birthday ")
        #expect(event.startDateSpecification.era == 1)
        #expect(event.targetYear == 2000)
        #expect(event.targetMonth == 4)
        #expect(event.targetDay == 8)
        #expect(event.targetHour == nil)
        #expect(event.timeSemantics == .floatingAllDay)
        #expect(event.timeZoneIdentifier == "GMT")
        #expect(event.repeatRule == .yearly)
        #expect(event.categoryID == BuiltInCategory.birthday.id)
        #expect(event.category?.id == BuiltInCategory.birthday.id)
        #expect(event.sourceKind == .contacts)
        #expect(event.createdAt == .mockNow)
        #expect(event.snapshotDigest == "imported-snapshot")
        #expect(
            event.conflictFingerprint
                == "1528b5726856c564d1e2c2ee4997c1a5e4c933ad7d86ebbf2f35016a0a37c235"
        )
        #expect(event.reminders?.isEmpty ?? true)
        #expect(event.currentRevisionID == eventID)
        #expect(try container.mainContext.fetch(FetchDescriptor<EventRevision>()).count == 1)
        #expect(!container.mainContext.hasChanges)
        #expect(refresher.refreshCount == 1)
    }

    @Test
    func writeWhenUpdatingThenReplacesTheContentAndAppendsARevision() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = SwiftDataEventRepository.mock(in: container)
        let eventID = UUID()
        try service.write([
            .create(id: eventID, .mockContactBirthday, category: .birthday, reminder: nil)
        ])
        let update = ImportedEventContent.mock(title: "Mary", day: 9, snapshotDigest: "updated")

        // When
        try service.write([.update(eventID: eventID, update)])

        // Then
        let event = try #require(
            try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        let revisions = try container.mainContext.fetch(FetchDescriptor<EventRevision>())
        #expect(event.title == "Mary")
        #expect(event.targetDay == 9)
        #expect(event.snapshotDigest == "updated")
        #expect(event.conflictFingerprint == EventContentFingerprint(event).rawValue)
        #expect(revisions.count == 2)
        #expect(revisions.first { $0.id == event.currentRevisionID }?.parentRevisionID == eventID)
    }

    @Test
    func writeWhenKeepingTheUserVersionThenOnlyRemembersTheSourceInANewRevision() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = SwiftDataEventRepository.mock(in: container)
        let eventID = UUID()
        try service.write([
            .create(id: eventID, .mockContactBirthday, category: .birthday, reminder: nil)
        ])
        let event = try #require(
            try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        let importedFingerprint = event.conflictFingerprint

        // When
        try service.write([.keep(eventID: eventID, snapshotDigest: "newer-source")])

        // Then
        #expect(event.title == "  Mary’s Birthday ")
        #expect(event.snapshotDigest == "newer-source")
        #expect(event.conflictFingerprint == importedFingerprint)
        #expect(try container.mainContext.fetch(FetchDescriptor<EventRevision>()).count == 2)
    }

    @Test
    func writeWhenAReminderComesWithANewEventThenStoresItsRule() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = SwiftDataEventRepository.mock(in: container)
        let reminder = ReminderDraft(daysBefore: 3, hour: 8, minute: 30)

        // When
        try service.write([
            .create(id: UUID(), .mockContactBirthday, category: .birthday, reminder: reminder)
        ])

        // Then
        let rules = try container.mainContext.fetch(FetchDescriptor<ReminderRule>())
        #expect(rules.map(\.id) == [reminder.id])
        #expect(rules.map(\.daysBefore) == [3])
        #expect(rules.map(\.hour) == [8])
        #expect(rules.map(\.minute) == [30])
        #expect(rules.first?.event?.reminders?.count == 1)
    }

    @Test
    func writeWhenTheEventIsMissingThenSkipsTheChange() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = SwiftDataEventRepository.mock(in: container)

        // When
        try service.write([
            .update(eventID: UUID(), .mockContactBirthday),
            .keep(eventID: UUID(), snapshotDigest: "newer-source"),
        ])

        // Then
        #expect(try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).isEmpty)
        #expect(try container.mainContext.fetch(FetchDescriptor<EventRevision>()).isEmpty)
    }

    @Test
    func writeWhenTheStoreRejectsTheSaveThenRollsBackAndDoesNotRefresh() throws {
        // Given
        let store = try ReadOnlyStore(seededWith: [])
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: store.container, refresher: refresher)

        // When / Then
        #expect(throws: EventError.storeFailure) {
            try service.write([
                .create(id: UUID(), .mockContactBirthday, category: .birthday, reminder: nil)
            ])
        }
        #expect(try store.container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).isEmpty)
        #expect(refresher.refreshCount == 0)
    }
}
