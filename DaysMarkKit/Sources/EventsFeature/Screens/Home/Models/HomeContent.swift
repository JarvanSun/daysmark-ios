//
//  HomeContent.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import DesignSystem
import Foundation

struct HomeContent {
    let pinned: Row?
    let horizon: [LandscapeMarker]
    let categories: [Category]
    let filter: HomeFilter
    let rows: [Row]
    let pinnedEventID: CountdownEvent.ID?
    let hasEvents: Bool
    let nextChange: Date?

    var showsOverview: Bool {
        hasEvents && !filter.isSearching
    }

    var selectableIDs: Set<CountdownEvent.ID> {
        Set(rows.map(\.id))
    }

    var newEventCategoryID: EventCategory.ID {
        hasEvents ? filter.categoryID ?? BuiltInCategory.important.id : BuiltInCategory.important.id
    }

    var placeholder: Placeholder? {
        switch (hasEvents, selectableIDs.isEmpty) {
        case (false, _): .noEvents
        case (true, false): nil
        case (true, true) where filter.isSearching: .noSearchResults(filter.query)
        case (true, true): filter.categoryID == nil ? nil : .noMatches
        }
    }

    func pinAction(for id: CountdownEvent.ID) -> PinAction {
        PinAction(for: id, pinnedEventID: pinnedEventID)
    }

    func row(_ id: CountdownEvent.ID) -> Row? {
        rows.first { $0.id == id }
    }
}

extension HomeContent {
    enum Placeholder: Equatable {
        case noEvents
        case noMatches
        case noSearchResults(String)
    }

    struct Category: Identifiable, Equatable {
        let id: EventCategory.ID?
        let name: String?
        let isSelected: Bool
    }

    struct Row: Identifiable {
        let event: EventItem
        let pinAction: PinAction

        var id: CountdownEvent.ID { event.id }
    }
}
