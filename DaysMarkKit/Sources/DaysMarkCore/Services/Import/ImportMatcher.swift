//
//  ImportMatcher.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@MainActor
struct ImportMatcher {
    private(set) var hasChangedReferences = false

    private let events: [CountdownEvent]
    private let references: [LocalSourceReference]
    private let localContext: ModelContext

    private var claimedEventIDs: Set<CountdownEvent.ID>

    init(
        events: [CountdownEvent],
        references: [LocalSourceReference],
        localContext: ModelContext
    ) {
        self.events = events
        self.references = references
        self.localContext = localContext
        claimedEventIDs = Set(references.map(\.eventID))
    }

    mutating func result(for item: ImportedDate) -> ImportResult {
        let digest = ImportSourceDigest(item).rawValue

        guard let event = event(for: item, digest: digest) else {
            return ImportResult(item: item, eventID: nil, decision: .create)
        }

        return ImportResult(
            item: item,
            eventID: event.id,
            decision: decision(for: digest, stored: event)
        )
    }

    private mutating func event(for item: ImportedDate, digest: String) -> CountdownEvent? {
        let reference = references.first {
            $0.sourceKindRaw == item.sourceKind.rawValue
                && $0.rawIdentifier == item.sourceIdentifier
        }
        let referenced = reference.flatMap { reference in
            events.first { $0.id == reference.eventID }
        }

        switch (referenced, reference) {
        case (let referenced?, _):
            return referenced
        case (nil, let orphaned?):
            localContext.delete(orphaned)
            hasChangedReferences = true
        case (nil, nil):
            break
        }

        return adoptSyncedEvent(for: item, digest: digest)
    }

    private mutating func adoptSyncedEvent(for item: ImportedDate, digest: String)
        -> CountdownEvent?
    {
        let event =
            events
            .filter {
                !claimedEventIDs.contains($0.id)
                    && $0.sourceKind == item.sourceKind
                    && $0.snapshotDigest == digest
            }
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .first

        guard let event else { return nil }

        claimedEventIDs.insert(event.id)
        localContext.insert(
            LocalSourceReference(
                eventID: event.id,
                sourceKind: item.sourceKind,
                rawIdentifier: item.sourceIdentifier
            )
        )
        hasChangedReferences = true

        return event
    }

    private func decision(for digest: String, stored event: CountdownEvent) -> ImportDecision {
        let isDeleted = event.deletedAt != nil
        let isSameSource = event.snapshotDigest == digest
        let isUntouched = event.conflictFingerprint == EventContentFingerprint(event).rawValue

        return switch (isDeleted, isSameSource, isUntouched) {
        case (true, _, _): .deleted
        case (false, true, _): .unchanged
        case (false, false, true): .change
        case (false, false, false): .conflict
        }
    }
}
