//
//  ImportServiceWritingTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct ImportServiceWritingTests {
    @Test
    func writeWhenTheDateIsNewThenCreatesTheEventAndKeepsItsIdentifierOnThisDevice() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let service = ImportService.mock(in: synced, localSources: localSources)
        let item = ImportedDate.mockContactBirthday
        let scanned = try service.results(for: [item])

        // When
        try service.write(scanned, resolutions: [:], reminders: [:])

        // Then
        let event = try #require(
            try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        let references = try localSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>())
        #expect(scanned.map(\.decision) == [.create])
        #expect(event.sourceKind == .contacts)
        #expect(event.categoryID == BuiltInCategory.birthday.id)
        #expect(event.reminders?.isEmpty ?? true)
        #expect(event.snapshotDigest?.contains(item.sourceIdentifier) == false)
        #expect(references.map(\.rawIdentifier) == [item.sourceIdentifier])
        #expect(references.map(\.eventID) == [event.id])
        #expect(try service.results(for: [item]).map(\.decision) == [.unchanged])
    }

    @Test
    func writeWhenTheSourceChangedThenUpdatesTheEventInANewRevision() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let service = ImportService.mock(in: synced, localSources: .mockLocalSources())
        try service.write(
            try service.results(for: [.mockContactBirthday]),
            resolutions: [:],
            reminders: [:]
        )
        let changed = ImportedDate.mock(title: "Mary Birthday", date: .mock(2000, 4, 9, hour: 0))
        let rescanned = try service.results(for: [changed])

        // When
        try service.write(rescanned, resolutions: [:], reminders: [:])

        // Then
        let event = try #require(
            try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        #expect(rescanned.map(\.decision) == [.change])
        #expect(event.title == "Mary Birthday")
        #expect(event.targetDay == 9)
        #expect(try synced.mainContext.fetch(FetchDescriptor<EventRevision>()).count == 2)
        #expect(try service.results(for: [changed]).map(\.decision) == [.unchanged])
    }

    @Test(arguments: [ImportResolution.keepMine, .importSource])
    func writeWhenAConflictIsResolvedThenFollowsTheResolutionAndRemembersTheSource(
        resolution: ImportResolution
    ) throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let service = ImportService.mock(in: synced, localSources: .mockLocalSources())
        try service.write(
            try service.results(for: [.mockContactBirthday]),
            resolutions: [:],
            reminders: [:]
        )
        let event = try #require(
            try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        event.title = "My Mary"
        try synced.mainContext.save()
        let update = ImportedDate.mock(title: "Mary Birthday", date: .mock(2000, 4, 9, hour: 0))
        let rescanned = try service.results(for: [update])

        // When
        try service.write(rescanned, resolutions: [update.id: resolution], reminders: [:])

        // Then
        let expectedTitle =
            switch resolution {
            case .keepMine: "My Mary"
            case .importSource: "Mary Birthday"
            }
        #expect(rescanned.map(\.decision) == [.conflict])
        #expect(event.title == expectedTitle)
        #expect(event.snapshotDigest == ImportSourceDigest(update).rawValue)
        #expect(try synced.mainContext.fetch(FetchDescriptor<EventRevision>()).count == 2)
        #expect(try service.results(for: [update]).map(\.decision) == [.unchanged])
    }

    @Test
    func writeWhenAConflictHasNoResolutionThenLeavesTheEventAlone() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let service = ImportService.mock(in: synced, localSources: .mockLocalSources())
        try service.write(
            try service.results(for: [.mockContactBirthday]),
            resolutions: [:],
            reminders: [:]
        )
        let event = try #require(
            try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        event.title = "My Mary"
        try synced.mainContext.save()
        let update = ImportedDate.mock(title: "Mary Birthday")

        // When
        try service.write(try service.results(for: [update]), resolutions: [:], reminders: [:])

        // Then
        #expect(event.title == "My Mary")
        #expect(try service.results(for: [update]).map(\.decision) == [.conflict])
    }

    @Test
    func writeWhenTheImportedEventWasDeletedThenDoesNotCreateItAgain() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let service = ImportService.mock(in: synced, localSources: localSources)
        let item = ImportedDate.mockContactBirthday
        try service.write(try service.results(for: [item]), resolutions: [:], reminders: [:])
        let event = try #require(
            try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        try SwiftDataEventRepository.mock(in: synced).delete(eventID: event.id)
        let rescanned = try service.results(for: [item])

        // When
        try service.write(rescanned, resolutions: [item.id: .importSource], reminders: [:])

        // Then
        #expect(rescanned.map(\.decision) == [.deleted])
        #expect(try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
        #expect(
            try localSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>()).count == 1
        )
    }

    @Test
    func writeWhenAReminderWasChosenThenStoresItWithTheEventAndItsRevision() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let service = ImportService.mock(in: synced, localSources: .mockLocalSources())
        let item = ImportedDate.mockContactBirthday

        // When
        try service.write(
            try service.results(for: [item]),
            resolutions: [:],
            reminders: [item.id: ImportReminderConfiguration(daysBefore: 3, hour: 8, minute: 30)]
        )

        // Then
        let event = try #require(
            try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        let reminder = try #require(event.reminders?.first)
        let revision = try #require(
            try synced.mainContext.fetch(FetchDescriptor<EventRevision>()).first
        )
        #expect(event.reminders?.count == 1)
        #expect(reminder.daysBefore == 3)
        #expect(reminder.hour == 8)
        #expect(reminder.minute == 30)
        #expect(reminder.kind == .allDayOffsetAtTime)
        #expect(revision.ordinaryReminderSnapshotData != nil)
    }

    @Test
    func writeWhenTheEventsCannotBeSavedThenRemovesTheSavedReferencesAndCanBeRetried() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let failing = ImportService.mock(
            in: synced,
            localSources: localSources,
            events: EventRepositorySpy(error: .storeFailure)
        )
        let retrying = ImportService.mock(in: synced, localSources: localSources)
        let scanned = try failing.results(for: [.mockContactBirthday])

        // When
        #expect(throws: ImportError.storeFailure) {
            try failing.write(scanned, resolutions: [:], reminders: [:])
        }
        let referencesAfterFailure = try localSources.mainContext.fetch(
            FetchDescriptor<LocalSourceReference>()
        )
        try retrying.write(scanned, resolutions: [:], reminders: [:])

        // Then
        #expect(referencesAfterFailure.isEmpty)
        #expect(try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
        #expect(
            try localSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>()).count == 1
        )
    }

    @Test
    func writeWhenBuiltInCategoriesCannotBeSeededThenSavesNothing() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let localSources = ModelContainer.mockLocalSources()
        let events = EventRepositorySpy()
        let service = ImportService.mock(
            in: synced,
            localSources: localSources,
            events: events,
            categories: CategoryRepositorySpy(error: .storeFailure)
        )
        let scanned = try service.results(for: [.mockContactBirthday])

        // When / Then
        #expect(throws: ImportError.storeFailure) {
            try service.write(scanned, resolutions: [:], reminders: [:])
        }
        #expect(events.writes.isEmpty)
        #expect(
            try localSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>()).isEmpty
        )
    }

    @Test
    func resultsWhenASyncedImportIsScannedOnAnotherDeviceThenSavesItsReferenceHere() throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let first = ImportService.mock(in: synced, localSources: .mockLocalSources())
        try first.write(
            try first.results(for: [.mockContactBirthday]),
            resolutions: [:],
            reminders: [:]
        )
        let secondDeviceSources = ModelContainer.mockLocalSources()
        let second = ImportService.mock(in: synced, localSources: secondDeviceSources)
        let scannedInTokyo = ImportedDate.mock(
            sourceIdentifier: "second-device-contact-id",
            date: .mock(2000, 4, 8, hour: 0, in: .mockTokyo),
            timeZone: .mockTokyo
        )

        // When
        let results = try second.results(for: [scannedInTokyo])

        // Then
        let event = try #require(
            try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).first
        )
        let reference = try #require(
            try secondDeviceSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>()).first
        )
        #expect(results.map(\.decision) == [.unchanged])
        #expect(try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
        #expect(reference.eventID == event.id)
        #expect(reference.rawIdentifier == "second-device-contact-id")
        #expect(!secondDeviceSources.mainContext.hasChanges)
    }

    @Test
    func resultsWithoutALocalSourceStoreThenThrowsLocalStoreUnavailable() {
        // Given
        let service = ImportService.mock(in: .mockInMemory(), localSources: nil)

        // When / Then
        #expect(throws: ImportError.localStoreUnavailable) {
            try service.results(for: [.mockContactBirthday])
        }
        #expect(throws: ImportError.localStoreUnavailable) {
            try service.write([], resolutions: [:], reminders: [:])
        }
    }
}
