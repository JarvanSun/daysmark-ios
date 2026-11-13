//
//  CountdownWidgetSource.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore

enum CountdownWidgetSource: String, AppEnum, Sendable {
    case automaticFocus
    case event
    case category
    case allEvents

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "widget.source.type")

    static let caseDisplayRepresentations: [CountdownWidgetSource: DisplayRepresentation] = [
        .automaticFocus: "widget.source.automaticFocus",
        .event: "widget.source.singleEvent",
        .category: "widget.source.singleCategory",
        .allEvents: "widget.source.allEvents",
    ]

    func contentSource(
        event: CountdownWidgetEventEntity?,
        category: CountdownWidgetCategoryEntity?
    ) -> WidgetContentSource {
        switch self {
        case .automaticFocus: .automaticFocus
        case .event: .event(event?.id)
        case .category: .category(category?.id)
        case .allEvents: .allEvents
        }
    }
}
