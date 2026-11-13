//
//  EventSeedWriterTests.swift
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
struct SwiftDataEventRepositorySeedsTests {
    @Test
    func seedThenStoresTheSeededEventWithItsCategoryAndRootRevision() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try SwiftDataCategoryRepository.mock(in: container).seedBuiltInCategories()
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: container, refresher: refresher)

        // When
        try service.seed([.mockNewYear])

        // Then
        let event = try #require(
            try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        #expect(event.id == .mockSeedID)
        #expect(event.recordID == .mockSeedID)
        #expect(event.seedIdentifier == "onboarding.new-year.v1")
        #expect(event.title == "New Year")
        #expect(event.targetYear == 2027)
        #expect(event.repeatRule == .yearly)
        #expect(event.sourceKind == .seeded)
        #expect(event.categoryID == BuiltInCategory.important.id)
        #expect(event.category?.id == BuiltInCategory.important.id)
        #expect(event.reminders?.isEmpty ?? true)
        #expect(event.createdAt == .mockNow)
        #expect(event.currentRevisionID == .mockSeedID)
        #expect(!container.mainContext.hasChanges)
        #expect(refresher.refreshCount == 1)
    }

    @Test
    func seedWhenRepeatedThenKeepsOneEvent() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = SwiftDataEventRepository.mock(in: container)
        try service.seed([.mockNewYear])

        // When
        try service.seed([.mockNewYear])

        // Then
        #expect(try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
        #expect(try container.mainContext.fetch(FetchDescriptor<EventRevision>()).count == 1)
    }

    @Test
    func seedWhenTheSeedWasDeletedPermanentlyThenDoesNotBringItBack() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        container.mainContext.insert(
            PermanentDeletionMarker(
                eventID: .mockSeedID,
                seedIdentifier: "onboarding.new-year.v1",
                deletedAt: .mockNow
            )
        )
        try container.mainContext.save()

        // When
        try SwiftDataEventRepository.mock(in: container).seed([.mockNewYear])

        // Then
        #expect(try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).isEmpty)
    }

    @Test
    func seedWithRemindersThenStoresTheirRules() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let reminders = [7, 1, 0].map { ReminderDraft(daysBefore: $0, hour: 9, minute: 0) }

        // When
        try SwiftDataEventRepository.mock(in: container)
            .seed([.mock(category: .birthday, reminders: reminders)])

        // Then
        let event = try #require(
            try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        let rules = event.reminders ?? []
        #expect(Set(rules.map(\.daysBefore)) == [7, 1, 0])
        #expect(rules.allSatisfy { $0.hour == 9 && $0.minute == 0 && $0.eventID == event.id })
    }

    @Test
    func seedWhenTheStoreRejectsTheSaveThenRollsBackAndDoesNotRefresh() throws {
        // Given
        let store = try ReadOnlyStore(seededWith: [])
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: store.container, refresher: refresher)

        // When / Then
        #expect(throws: EventError.storeFailure) { try service.seed([.mockNewYear]) }
        #expect(try store.container.mainContext.fetch(FetchDescriptor<CountdownEvent>()).isEmpty)
        #expect(refresher.refreshCount == 0)
    }
}
