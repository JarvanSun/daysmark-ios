//
//  HomeData.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import DesignSystem
import Foundation

struct HomeData {
    var events: [CountdownEvent] = []
    var categories: [EventCategory] = []
    var pinnedEventID: CountdownEvent.ID?

    func content(filter: HomeFilter, at time: CurrentTime) -> HomeContent {
        let sorter = EventSorter()
        let activeEvents = events.filter { $0.deletedAt == nil }
        let counted = sorter.counted(activeEvents, now: time.now, userTimeZone: time.timeZone)
        let ordered = sorter.ordered(counted)
        let offered = offeredCategories(including: filter.categoryID)
        var filter = filter
        filter.categoryID = sorter.effectiveFilter(filter.categoryID, in: offered)
        let categoryNames = namesByCategoryID()
        let shown = ordered.filter {
            filter.shows($0.event, categoryName: categoryNames[$0.event.categoryID])
        }

        return HomeContent(
            pinned: sorter.focus(among: counted, focusedEventID: pinnedEventID)
                .map { row(for: $0, at: time) },
            horizon: ordered.compactMap(\.dayCount.landscapeMarker),
            categories: categoryChoices(offered, selected: filter.categoryID),
            filter: filter,
            rows: shown.map { row(for: $0, at: time) },
            pinnedEventID: pinnedEventID,
            hasEvents: !activeEvents.isEmpty,
            nextChange: EventBrowseRefreshPlanner()
                .nextBoundary(after: time.now, items: counted, userTimeZone: time.timeZone)
        )
    }

    private func offeredCategories(including selectedID: EventCategory.ID?) -> [EventCategory] {
        let missingBuiltIns = BuiltInCategory.allCases
            .filter { kind in !categories.contains { $0.id == kind.id } }
            .map(EventCategory.init(builtIn:))
        let unique = Dictionary((missingBuiltIns + categories).map { ($0.id, $0) }) { _, last in
            last
        }

        return unique.values
            .filter { isOffered($0) || $0.id == selectedID && $0.deletedAt == nil }
            .sorted { ($0.sortOrder, $0.id.uuidString) < ($1.sortOrder, $1.id.uuidString) }
    }

    private func isOffered(_ category: EventCategory) -> Bool {
        category.builtInKind != nil || (!category.isBuiltIn && category.deletedAt == nil)
    }

    private func namesByCategoryID() -> [EventCategory.ID: String] {
        let builtIn = BuiltInCategory.allCases.map { ($0.id, $0.displayName) }
        let stored = categories.map { ($0.id, $0.displayName) }

        return Dictionary(builtIn + stored) { _, stored in stored }
    }

    private func row(for counted: EventDayCount, at time: CurrentTime) -> HomeContent.Row {
        HomeContent.Row(
            event: EventItem(counted, at: time),
            pinAction: PinAction(for: counted.id, pinnedEventID: pinnedEventID)
        )
    }

    private func categoryChoices(
        _ categories: [EventCategory],
        selected: EventCategory.ID?
    ) -> [HomeContent.Category] {
        [HomeContent.Category(id: nil, name: nil, isSelected: selected == nil)]
            + categories.map {
                HomeContent.Category(id: $0.id, name: $0.displayName, isSelected: $0.id == selected)
            }
    }

    func target(of request: AppRequest) -> RequestTarget? {
        RequestTarget(request, events: events, categories: categories)
    }
}
