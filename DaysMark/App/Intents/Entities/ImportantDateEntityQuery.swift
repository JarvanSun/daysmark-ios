//
//  ImportantDateEntityQuery.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct ImportantDateEntityQuery: EntityStringQuery {
    @Dependency private var lookup: EventLookup

    func entities(for identifiers: [UUID]) async throws -> [ImportantDateEntity] {
        await lookup.events(withIDs: identifiers).map(ImportantDateEntity.init)
    }

    func entities(matching string: String) async throws -> [ImportantDateEntity] {
        await lookup.events(titled: string).map(ImportantDateEntity.init)
    }

    func suggestedEntities() async throws -> [ImportantDateEntity] {
        await lookup.nearestEvents(limit: suggestionCount, in: nil).map(ImportantDateEntity.init)
    }

    private var suggestionCount: Int { 3 }
}
