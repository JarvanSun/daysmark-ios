//
//  FocusSelectionWriter.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation
import SwiftData

@MainActor
struct FocusSelectionWriter {
    let context: ModelContext

    private let resolver = FocusSelectionResolver()

    func selectedEventID() throws -> UUID? {
        resolver.selectedEventID(
            selections: try context.fetch(FetchDescriptor<FocusSelection>()),
            revisions: try context.fetch(FetchDescriptor<FocusSelectionRevision>())
        )
    }

    func select(_ eventID: UUID?, at date: Date) throws {
        guard try isSelectable(eventID) else { return }

        let existing = try canonicalSelection()
        let selection =
            existing ?? FocusSelection(id: selectionID, eventID: nil, updatedAt: date)

        if existing == nil {
            context.insert(selection)
        }

        let revisions = try context.fetch(FetchDescriptor<FocusSelectionRevision>())
        let material = resolver.materialWinner(revisions)

        guard material?.eventID != eventID || material == nil else { return }

        let parentRevisionID = material?.id ?? selection.currentRevisionID
        let revision = FocusSelectionRevision(
            parentRevisionID: parentRevisionID,
            conflictGroupID: material?.conflictGroupID ?? parentRevisionID ?? rootConflictGroupID,
            eventID: eventID,
            createdAt: date
        )
        context.insert(revision)
        selection.eventID = eventID
        selection.currentRevisionID = revision.id
        selection.updatedAt = date

        try context.save()
    }

    private var selectionID: UUID { UUID(fixedGroup: 0xF0C0_0000, number: 0x04) }

    private var rootConflictGroupID: UUID { UUID(fixedGroup: 0xF0C0_0000, number: 0x10) }

    private func isSelectable(_ eventID: UUID?) throws -> Bool {
        guard let eventID else { return true }

        return try context.fetch(FetchDescriptor<CountdownEvent>()).contains {
            $0.id == eventID && $0.deletedAt == nil && $0.permanentDeletionRequestedAt == nil
        }
    }

    private func canonicalSelection() throws -> FocusSelection? {
        try context.fetch(FetchDescriptor<FocusSelection>())
            .min { $0.recordID.uuidString < $1.recordID.uuidString }
    }

    func clearIfSelecting(_ eventID: UUID, at date: Date) throws {
        guard try selectedEventID() == eventID else { return }

        try select(nil, at: date)
    }

    func repair(now: Date) throws {
        guard let selection = try convergedSelection() else { return }

        let revisions = try context.fetch(FetchDescriptor<FocusSelectionRevision>())

        if let winner = resolver.materialWinner(revisions) {
            selection.eventID = winner.eventID
            selection.currentRevisionID = winner.id
            selection.updatedAt = winner.createdAt
        }

        switch try selectsDeletedEvent(selection) {
        case true: try select(nil, at: now)
        case false: try context.save()
        }
    }

    private func convergedSelection() throws -> FocusSelection? {
        let selections = try context.fetch(FetchDescriptor<FocusSelection>())
        let canonical = selections.min { $0.recordID.uuidString < $1.recordID.uuidString }

        for duplicate in selections where duplicate !== canonical {
            context.delete(duplicate)
        }

        return canonical
    }

    private func selectsDeletedEvent(_ selection: FocusSelection) throws -> Bool {
        guard let selectedID = selection.eventID else { return false }

        let event = try context.fetch(
            FetchDescriptor<CountdownEvent>(predicate: #Predicate { $0.id == selectedID })
        ).first

        guard let event else {
            return try !context.fetch(
                FetchDescriptor<PermanentDeletionMarker>(
                    predicate: #Predicate { $0.eventID == selectedID }
                )
            ).isEmpty
        }

        return event.deletedAt != nil || event.permanentDeletionRequestedAt != nil
    }
}
