//
//  EventRevisionWriter.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import SwiftData

@MainActor
struct EventRevisionWriter {
    let context: ModelContext

    var rootConflictGroupID: UUID { UUID(fixedGroup: 0x0000_0000, number: 0x10) }

    func appendInitialRevision(for event: CountdownEvent, at date: Date) {
        guard event.currentRevisionID == nil else { return }

        let revision = EventRevision(
            id: event.id,
            eventID: event.id,
            parentRevisionID: nil,
            conflictGroupID: rootConflictGroupID,
            createdAt: date,
            event: event
        )
        context.insert(revision)
        event.currentRevisionID = revision.id
    }

    func appendContentRevision(
        for event: CountdownEvent,
        at date: Date,
        parentRevisionID: UUID? = nil,
        superseding revisionIDs: [UUID] = []
    ) {
        let parent = parentRevisionID ?? event.currentRevisionID
        let revision = EventRevision(
            eventID: event.id,
            parentRevisionID: parent,
            conflictGroupID: parent ?? rootConflictGroupID,
            supersededRevisionIDs: revisionIDs,
            createdAt: date,
            event: event
        )
        context.insert(revision)
        event.currentRevisionID = revision.id
    }

    func unresolvedRevisionIDs(eventID: UUID) throws -> Set<UUID> {
        let revisions = try context.fetch(FetchDescriptor<EventRevision>())
            .filter { $0.eventID == eventID }
        let superseded = Set(revisions.flatMap(\.supersededRevisionIDs))
        let siblings = Dictionary(grouping: revisions, by: \.conflictGroupID).values
            .flatMap { group in
                let unique = Dictionary(grouping: group, by: \.id).compactMap(\.value.first)

                return unique.count > 1 ? unique.filter { !superseded.contains($0.id) } : []
            }
        let resolutionConflicts = conflictingResolutions(in: revisions, superseded: superseded)

        return Set((siblings + resolutionConflicts).map(\.id))
    }

    private func conflictingResolutions(
        in revisions: [EventRevision],
        superseded: Set<UUID>
    ) -> [EventRevision] {
        let revisionsByID = Dictionary(grouping: revisions, by: \.id).compactMapValues(\.first)
        let liveResolutions = revisions.filter {
            !$0.supersededRevisionIDs.isEmpty && !superseded.contains($0.id)
        }
        var byCausalKey: [String: [EventRevision]] = [:]

        for resolution in liveResolutions {
            var keys = Set(resolution.supersededRevisionIDs.map { "revision:\($0.uuidString)" })

            for supersededID in resolution.supersededRevisionIDs {
                if let groupID = revisionsByID[supersededID]?.conflictGroupID {
                    keys.insert("group:\(groupID.uuidString)")
                }
            }

            for key in keys {
                byCausalKey[key, default: []].append(resolution)
            }
        }

        return byCausalKey.values.flatMap { group in
            let unique = Dictionary(grouping: group, by: \.id).compactMap(\.value.first)

            return unique.count > 1 ? unique : []
        }
    }
}
