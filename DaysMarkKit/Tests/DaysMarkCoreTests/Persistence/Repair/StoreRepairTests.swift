//
//  StoreRepairTests.swift
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
struct StoreRepairTests {
    @Test
    func repairThenPurgesExpiredDeletionsAndFinishesLocalCleanup() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try SwiftDataCategoryRepository.mock(in: container).seedBuiltInCategories()
        let localSources = ModelContainer.mockLocalSources()
        var now = Date.mockNow
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(
            in: container,
            localSources: localSources,
            refresher: refresher,
            now: { now }
        )
        let expiredID = try service.save(.mock("Expired"), replacing: nil)
        let keptID = try service.save(.mock("Kept"), replacing: nil)
        try service.delete(eventID: expiredID)
        localSources.mainContext.insert(
            LocalSourceCleanupRequest(eventID: UUID(), requestedAt: .mockNow)
        )
        try localSources.mainContext.save()
        let refreshCount = refresher.refreshCount
        now += EventLifecycle(context: container.mainContext).retention + 1

        // When
        try StoreRepair(container: container, localSources: localSources, now: { now }).run()

        // Then
        let context = container.mainContext
        let markers = try context.fetch(FetchDescriptor<PermanentDeletionMarker>())
        #expect(try context.fetch(FetchDescriptor<EventCategory>()).count == 3)
        #expect(try context.fetch(FetchDescriptor<CountdownEvent>()).map(\.id) == [keptID])
        #expect(markers.map(\.eventID) == [expiredID])
        #expect(
            try localSources.mainContext.fetch(FetchDescriptor<LocalSourceCleanupRequest>()).isEmpty
        )
        #expect(refresher.refreshCount == refreshCount)
    }

    @Test
    func repairWhenRunTwiceThenChangesNothingTheSecondTime() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        try SwiftDataCategoryRepository.mock(in: container).seedBuiltInCategories()
        let localSources = ModelContainer.mockLocalSources()
        let service = SwiftDataEventRepository.mock(in: container, localSources: localSources)
        let repair = StoreRepair(
            container: container,
            localSources: localSources,
            now: { .mockNow }
        )
        try service.save(.mock("Trip"), replacing: nil)
        try repair.run()
        let context = container.mainContext
        let revisionIDs = try context.fetch(FetchDescriptor<EventRevision>()).map(\.id)
        let focusRevisionIDs = try context.fetch(FetchDescriptor<FocusSelectionRevision>()).map(
            \.id
        )

        // When
        try repair.run()

        // Then
        #expect(try context.fetch(FetchDescriptor<EventRevision>()).map(\.id) == revisionIDs)
        #expect(
            try context.fetch(FetchDescriptor<FocusSelectionRevision>()).map(\.id)
                == focusRevisionIDs
        )
        #expect(try context.fetch(FetchDescriptor<EventCategory>()).count == 3)
        #expect(!context.hasChanges)
    }

    @Test
    func repairWhenTheBuiltInCategoriesAreMissingThenThrowsStoreFailure() {
        // Given
        let repair = StoreRepair(container: .mockInMemory(), localSources: nil, now: { .mockNow })

        // When / Then
        #expect(throws: EventError.storeFailure) { try repair.run() }
    }
}
