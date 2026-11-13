//
//  RequestTarget.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

enum RequestTarget: Equatable {
    case home(categoryID: EventCategory.ID?)
    case newEvent
    case search
    case detail(CountdownEvent.ID)
    case recentlyDeleted(CountdownEvent.ID)
    case widgets

    init?(_ request: AppRequest, events: [CountdownEvent], categories: [EventCategory]) {
        switch request {
        case .event(let id): self.init(eventID: id, in: events)
        case .category(let id): self.init(categoryID: id, in: categories)
        case .collection(let collection): self = .home(categoryID: collection.categoryID)
        case .widgets: self = .widgets
        case .newEvent: self = .newEvent
        case .search: self = .search
        }
    }

    private init?(eventID: CountdownEvent.ID, in events: [CountdownEvent]) {
        guard let event = events.first(where: { $0.id == eventID }) else { return nil }
        guard event.permanentDeletionRequestedAt == nil else { return nil }

        self = event.deletedAt == nil ? .detail(eventID) : .recentlyDeleted(eventID)
    }

    private init(categoryID: EventCategory.ID, in categories: [EventCategory]) {
        let exists = categories.contains { $0.id == categoryID && $0.deletedAt == nil }

        self = exists ? .home(categoryID: categoryID) : .widgets
    }
}
