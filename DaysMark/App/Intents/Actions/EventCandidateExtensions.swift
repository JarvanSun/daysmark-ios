//
//  EventCandidateExtensions.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore

extension EventCandidate {
    func save(to events: EventRepository, lookup: EventLookup) async throws -> ImportantDateEntity {
        let savedID: CountdownEvent.ID

        do {
            savedID = try await events.save(draft, replacing: eventID)
        } catch {
            throw ImportantDateIntentError(error)
        }

        guard let match = await lookup.events(withIDs: [savedID]).first else {
            throw AppIntentError.Unrecoverable.entityNotFound
        }

        return ImportantDateEntity(match)
    }
}
