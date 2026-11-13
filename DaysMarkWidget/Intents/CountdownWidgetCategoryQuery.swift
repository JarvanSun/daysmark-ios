//
//  CountdownWidgetCategoryQuery.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct CountdownWidgetCategoryQuery: EntityQuery, Sendable {
    private let reader = WidgetContentReader()

    func entities(for identifiers: [UUID]) async throws -> [CountdownWidgetCategoryEntity] {
        await reader.categoryOptions(withIDs: identifiers).map(CountdownWidgetCategoryEntity.init)
    }

    func suggestedEntities() async throws -> [CountdownWidgetCategoryEntity] {
        await reader.categoryOptions().map(CountdownWidgetCategoryEntity.init)
    }
}
