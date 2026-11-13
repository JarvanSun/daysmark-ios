//
//  WidgetStoreContents.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation

struct WidgetStoreContents {
    let events: [CountdownEvent]
    let categories: [EventCategory]
    let focusedEventID: CountdownEvent.ID?

    func events(relevantTo source: WidgetContentSource) -> [CountdownEvent] {
        switch source {
        case .automaticFocus, .allEvents: events
        case .event(let id): events.filter { $0.id == id }
        case .category(let id): events.filter { $0.categoryID == id }
        }
    }
}
