//
//  CountdownWidgetEventQuery.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct CountdownWidgetEventQuery: EntityStringQuery, Sendable {
    private let reader = WidgetContentReader()

    func entities(for identifiers: [UUID]) async throws -> [CountdownWidgetEventEntity] {
        await reader.eventOptions(withIDs: identifiers).map(CountdownWidgetEventEntity.init)
    }

    func suggestedEntities() async throws -> [CountdownWidgetEventEntity] {
        await reader.suggestedEventOptions(at: .now).map(CountdownWidgetEventEntity.init)
    }

    func entities(matching string: String) async throws -> [CountdownWidgetEventEntity] {
        await reader.eventOptions(titled: string, at: .now).map(CountdownWidgetEventEntity.init)
    }
}
