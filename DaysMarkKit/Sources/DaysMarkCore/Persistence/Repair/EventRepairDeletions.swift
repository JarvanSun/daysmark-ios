//
//  EventRepairDeletions.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import SwiftData

extension EventRepair {
    func applyDeletionRevisions(to events: [CountdownEvent]) throws {
        let revisionsByEventID = Dictionary(
            grouping: try context.fetch(FetchDescriptor<EventRevision>()),
            by: \.eventID
        )

        for event in events {
            applyDeletionRevisions(
                convergedRevisions(of: event, among: revisionsByEventID[event.id] ?? []),
                to: event
            )
        }
    }

    func convergedRevisions(
        of event: CountdownEvent,
        among eventRevisions: [EventRevision]
    ) -> [EventRevision] {
        let duplicateRoots = eventRevisions.filter {
            $0.parentRevisionID == nil && $0.id == event.id
        }

        guard duplicateRoots.count > 1,
            let canonicalRoot = duplicateRoots.min(by: {
                $0.recordID.uuidString < $1.recordID.uuidString
            })
        else { return eventRevisions }

        for duplicate in duplicateRoots where duplicate !== canonicalRoot {
            context.delete(duplicate)
        }

        if event.currentRevisionID == nil || event.currentRevisionID == event.id {
            event.currentRevisionID = canonicalRoot.id
        }

        return eventRevisions.filter { $0.parentRevisionID != nil || $0 === canonicalRoot }
    }

    func applyDeletionRevisions(
        _ eventRevisions: [EventRevision],
        to event: CountdownEvent
    ) {
        let restoredDeletionIDs = Set(eventRevisions.compactMap(\.restoredDeletionRevisionID))
        let byID = Dictionary(grouping: eventRevisions, by: \.id).compactMapValues(\.first)

        if let pendingID = event.deletionRevisionID, byID[pendingID] == nil {
            return
        }

        let deletion =
            eventRevisions
            .filter { $0.isDeletion && !restoredDeletionIDs.contains($0.id) }
            .max { $0.createdAt < $1.createdAt }
        let restoredID = event.deletionRevisionID.flatMap {
            restoredDeletionIDs.contains($0) ? $0 : nil
        }

        switch (deletion, restoredID) {
        case (let deletion?, _):
            event.deletedAt = deletion.createdAt
            event.deletionRevisionID = deletion.id

            if deletion.isPermanentDeletionRequest {
                event.permanentDeletionRequestedAt = deletion.createdAt
            }
        case (nil, .some):
            event.deletedAt = nil
            event.deletionRevisionID = nil
        case (nil, nil):
            break
        }
    }

    func applyDeletionMarkers(to events: [CountdownEvent]) throws {
        let permanentlyDeletedIDs = Dictionary(
            grouping: try context.fetch(FetchDescriptor<PermanentDeletionMarker>()),
            by: \.eventID
        ).compactMapValues { $0.map(\.deletedAt).min() }

        for event in events {
            guard let deletedAt = permanentlyDeletedIDs[event.id] else { continue }

            if event.deletedAt == nil {
                event.deletedAt = deletedAt
            }

            if event.permanentDeletionRequestedAt == nil {
                event.permanentDeletionRequestedAt = deletedAt
            }
        }
    }
}
