//
//  ImportantDateCategoryQuery.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct ImportantDateCategoryQuery: EntityStringQuery {
    @Dependency private var lookup: EventLookup

    func entities(for identifiers: [UUID]) async throws -> [ImportantDateCategoryEntity] {
        await lookup.categories(withIDs: identifiers).map(ImportantDateCategoryEntity.init)
    }

    func entities(matching string: String) async throws -> [ImportantDateCategoryEntity] {
        await lookup.categories(named: string).map(ImportantDateCategoryEntity.init)
    }

    func suggestedEntities() async throws -> [ImportantDateCategoryEntity] {
        await lookup.categories().map(ImportantDateCategoryEntity.init)
    }
}
