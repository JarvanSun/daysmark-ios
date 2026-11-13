//
//  LocalSourceCleanup.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@MainActor
struct LocalSourceCleanup {
    let context: ModelContext

    func request(for eventID: UUID, at date: Date) throws {
        do {
            let requests = try context.fetch(FetchDescriptor<LocalSourceCleanupRequest>())

            if !requests.contains(where: { $0.eventID == eventID }) {
                context.insert(LocalSourceCleanupRequest(eventID: eventID, requestedAt: date))
            }

            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func finish(for eventID: UUID) throws {
        do {
            for reference in try context.fetch(FetchDescriptor<LocalSourceReference>())
            where reference.eventID == eventID {
                context.delete(reference)
            }

            for request in try context.fetch(FetchDescriptor<LocalSourceCleanupRequest>())
            where request.eventID == eventID {
                context.delete(request)
            }

            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func finishInterrupted(comparingWith syncedContext: ModelContext) throws {
        let events = try syncedContext.fetch(FetchDescriptor<CountdownEvent>())
        let eventIDs = Set(events.map(\.id))
        let logicalPermanentIDs = Set(
            events.filter { $0.permanentDeletionRequestedAt != nil }.map(\.id)
        )
        let markerIDs = Set(
            try syncedContext.fetch(FetchDescriptor<PermanentDeletionMarker>()).map(\.eventID)
        )
        let requests = try context.fetch(FetchDescriptor<LocalSourceCleanupRequest>())
        let candidateIDs = Set(requests.map(\.eventID))
            .union(markerIDs)
            .union(logicalPermanentIDs)

        for eventID in candidateIDs
        where !eventIDs.contains(eventID) || logicalPermanentIDs.contains(eventID) {
            try finish(for: eventID)
        }
    }
}
