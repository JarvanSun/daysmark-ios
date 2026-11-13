//
//  FocusSelectionResolverTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct FocusSelectionResolverTests {
    @Test
    func selectedEventIDWhenSelectionsAreDuplicatedThenFollowsTheNewestRevision() {
        // Given
        let staleEvent = CountdownEvent.mock(title: "Stale")
        let currentEvent = CountdownEvent.mock(title: "Current")
        let staleRevision = FocusSelectionRevision(
            id: UUID(uuidString: "FFFFFFFF-FFFF-4FFF-8FFF-FFFFFFFFFFFF")!,
            parentRevisionID: nil,
            conflictGroupID: .mockFocusRootGroupID,
            eventID: staleEvent.id,
            createdAt: Date(timeIntervalSince1970: 10)
        )
        let currentRevision = FocusSelectionRevision(
            id: UUID(uuidString: "00000000-0000-4000-8000-000000000001")!,
            parentRevisionID: nil,
            conflictGroupID: .mockFocusRootGroupID,
            eventID: currentEvent.id,
            createdAt: Date(timeIntervalSince1970: 20)
        )
        let smallestRecord = FocusSelection.mock(
            recordID: UUID(uuidString: "00000000-0000-4000-8000-000000000001")!,
            eventID: staleEvent.id,
            currentRevisionID: staleRevision.id,
            updatedAt: staleRevision.createdAt
        )
        let otherRecord = FocusSelection.mock(
            recordID: UUID(uuidString: "FFFFFFFF-FFFF-4FFF-8FFF-FFFFFFFFFFFF")!,
            eventID: currentEvent.id,
            currentRevisionID: currentRevision.id,
            updatedAt: currentRevision.createdAt
        )

        // Then
        #expect(
            FocusSelectionResolver().selectedEventID(
                selections: [otherRecord, smallestRecord],
                revisions: [currentRevision, staleRevision]
            ) == currentEvent.id
        )
    }
}
