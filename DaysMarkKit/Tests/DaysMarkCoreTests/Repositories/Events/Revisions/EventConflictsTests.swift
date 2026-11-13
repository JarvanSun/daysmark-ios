//
//  EventConflictsTests.swift
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
struct SwiftDataEventRepositoryConflictsTests {
    @Test
    func versionsWithoutAConflictThenIsEmpty() throws {
        // Given
        let service = SwiftDataEventRepository.mock(in: .mockInMemory())
        let eventID = try service.save(.mock("Trip", on: .mock(2030, 1, 10)), replacing: nil)

        // When / Then
        #expect(try service.conflictVersions(of: eventID).isEmpty)
    }

    @Test
    func versionsWhenAStaleDraftWasSavedThenListsBothSiblings() throws {
        // Given
        let service = SwiftDataEventRepository.mock(in: .mockInMemory())
        let event = try service.create(from: .mock("Trip", on: .mock(2030, 1, 10)))
        try saveConflictingEdits(of: event, with: service)

        // When
        let versions = try service.conflictVersions(of: event.id)

        // Then
        #expect(versions.count == 2)
        #expect(Set(versions.map(\.draft.trimmedTitle)) == ["Trip", "Trip to Rome"])
    }

    @Test
    func resolveConflictThenKeepsTheChosenVersionAndRefreshes() throws {
        // Given
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: .mockInMemory(), refresher: refresher)
        let event = try service.create(from: .mock("Trip", on: .mock(2030, 1, 10)))
        try saveConflictingEdits(of: event, with: service)
        let versions = try service.conflictVersions(of: event.id)
        let remoteVersion = try #require(versions.first { $0.draft.trimmedTitle == "Trip" })
        let refreshCount = refresher.refreshCount

        // When
        try service.resolveConflict(eventID: event.id, keeping: remoteVersion.id)

        // Then
        #expect(try service.conflictVersions(of: event.id).isEmpty)
        #expect(event.title == "Trip")
        #expect(event.targetDay == 20)
        #expect(refresher.refreshCount == refreshCount + 1)
    }

    @Test
    func resolveConflictWhenTheVersionIsUnknownThenChangesNothing() throws {
        // Given
        let refresher = SystemSurfaceRefresherSpy()
        let service = SwiftDataEventRepository.mock(in: .mockInMemory(), refresher: refresher)
        let event = try service.create(from: .mock("Trip", on: .mock(2030, 1, 10)))
        try saveConflictingEdits(of: event, with: service)
        let revisionID = event.currentRevisionID
        let refreshCount = refresher.refreshCount

        // When
        try service.resolveConflict(eventID: event.id, keeping: UUID())

        // Then
        #expect(try service.conflictVersions(of: event.id).count == 2)
        #expect(event.currentRevisionID == revisionID)
        #expect(refresher.refreshCount == refreshCount)
    }

    @Test
    func resolveConflictWhenTheEventIsMissingThenThrowsEventUnavailable() {
        // Given
        let service = SwiftDataEventRepository.mock(in: .mockInMemory())

        // When / Then
        #expect(throws: EventError.eventUnavailable) {
            try service.resolveConflict(eventID: UUID(), keeping: UUID())
        }
    }

    private func saveConflictingEdits(
        of event: CountdownEvent,
        with service: SwiftDataEventRepository
    )
        throws
    {
        var stale = EventDraft.mock(of: event)
        var remote = EventDraft.mock(of: event)
        remote.targetDate = .mock(2030, 1, 20)
        try service.save(remote, replacing: event.id)

        stale.title = "Trip to Rome"
        try service.save(stale, replacing: event.id)
    }
}
