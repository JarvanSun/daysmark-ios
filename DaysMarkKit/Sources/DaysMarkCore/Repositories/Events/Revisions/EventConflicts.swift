//
//  EventConflicts.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/10/07.
//

import Foundation
import SwiftData

@MainActor
struct EventConflicts {
    let context: ModelContext
    let now: Date
    let timeZone: TimeZone

    func versions(of eventID: UUID) throws -> [EventConflictVersion] {
        let unresolved = try EventRevisionWriter(context: context)
            .unresolvedRevisionIDs(eventID: eventID)

        guard unresolved.count > 1 else { return [] }

        let contents = try contentRevisions(of: eventID, among: unresolved)

        guard contents.count > 1 else { return [] }

        return contents.sorted { $0.createdAt > $1.createdAt }.map(version)
    }

    private func contentRevisions(of eventID: UUID, among ids: Set<UUID>) throws -> [EventRevision]
    {
        let revisions = try context.fetch(
            FetchDescriptor<EventRevision>(predicate: #Predicate { $0.eventID == eventID })
        )

        return Dictionary(
            grouping: revisions.filter { ids.contains($0.id) && !$0.isDeletion },
            by: \.id
        )
        .compactMap(\.value.first)
    }

    private func version(of revision: EventRevision) -> EventConflictVersion {
        EventConflictVersion(
            id: revision.id,
            draft: EventDraft(revision, at: now, in: timeZone),
            createdAt: revision.createdAt
        )
    }
}

public struct EventConflictVersion: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let draft: EventDraft
    public let createdAt: Date

    public init(id: UUID, draft: EventDraft, createdAt: Date) {
        self.id = id
        self.draft = draft
        self.createdAt = createdAt
    }
}
