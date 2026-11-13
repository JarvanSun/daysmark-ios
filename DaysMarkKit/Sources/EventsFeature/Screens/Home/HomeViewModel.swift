//
//  HomeViewModel.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/07/25.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class HomeViewModel {
    var filter = HomeFilter()
    var isSearchPresented = false
    var isSelecting = false
    var selection: Set<CountdownEvent.ID> = []

    let time: CurrentTime
    private let events: EventRepository
    private let categories: CategoryRepository
    private let router: EventsRouting

    private(set) var data = HomeData()
    private(set) var issue: EventIssue?

    init(
        events: EventRepository,
        categories: CategoryRepository,
        time: CurrentTime,
        router: EventsRouting
    ) {
        self.events = events
        self.categories = categories
        self.time = time
        self.router = router
    }

    var content: HomeContent {
        data.content(filter: filter, at: time)
    }

    var title: String {
        isSelecting
            ? String(localized: "home.selection.count \(selection.count)", bundle: .module) : ""
    }

    func observeStore() async {
        reload()

        for await _ in events.changes() {
            reload()
        }
    }

    func reload() {
        do {
            data = try HomeData(
                events: events.events(),
                categories: categories.categories().filter { $0.deletedAt == nil },
                pinnedEventID: FocusSelectionResolver().selectedEventID(
                    selections: events.focusSelections(),
                    revisions: events.focusSelectionRevisions()
                )
            )
        } catch {
            issue = EventIssue(.storeFailure)
        }
    }

    func open(_ request: AppRequest) {
        switch data.target(of: request) {
        case .home(let categoryID): showHome(selecting: categoryID)
        case .newEvent: addEvent()
        case .search: showSearch()
        case .detail(let id): router.showRequestedDetail(for: id)
        case .recentlyDeleted(let id):
            router.showRequestedSettings(.recentlyDeleted(highlighting: id))
        case .widgets: router.showRequestedSettings(.widgets)
        case nil: break
        }
    }

    private func showHome(selecting categoryID: EventCategory.ID?) {
        guard !router.isPresentingSheet else { return }

        selectCategory(categoryID)
        router.showHome()
    }

    private func showSearch() {
        guard !isSelecting else { return }

        isSearchPresented = true
    }

    func addEvent() {
        guard !isSelecting else { return }

        router.showEditor(for: .new(categoryID: content.newEventCategoryID))
    }

    func open(_ id: CountdownEvent.ID) {
        router.showDetail(for: id)
    }

    func openPinned(_ id: CountdownEvent.ID) {
        router.showDetailFromFocus(for: id)
    }

    func share(_ id: CountdownEvent.ID) {
        router.showSharing(for: id)
    }

    func openSettings() {
        router.showSettings(.root)
    }

    func selectCategory(_ id: EventCategory.ID?) {
        filter.categoryID = id
        selection = []
    }

    func resetFilters() {
        selectCategory(nil)
    }

    func togglePin(_ id: CountdownEvent.ID) {
        let pinnedEventID = content.pinAction(for: id).pinnedEventID

        perform(try events.setFocus(eventID: pinnedEventID))
    }

    func delete(_ id: CountdownEvent.ID) {
        perform(try events.delete(eventID: id))
    }

    func startSelecting() {
        isSelecting = true
    }

    func finishSelecting() {
        selection = []
        isSelecting = false
    }

    func selectAll() {
        selection = content.selectableIDs
    }

    func deleteSelection() {
        let ids = selection.intersection(content.selectableIDs).sorted {
            $0.uuidString < $1.uuidString
        }
        var failed: Set<CountdownEvent.ID> = []

        for id in ids where !perform(try events.delete(eventID: id)) {
            failed.insert(id)
        }

        selection = failed
        issue = failed.isEmpty ? nil : .batchDeleteFailed(count: failed.count)
        finishSelectingWhenEmpty()
    }

    private func finishSelectingWhenEmpty() {
        guard selection.isEmpty else { return }

        isSelecting = false
    }

    func acknowledgeIssue() {
        issue = nil
    }

    @discardableResult
    private func perform(_ change: @autoclosure () throws(EventError) -> Void) -> Bool {
        do {
            try change()
            issue = nil
            return true
        } catch {
            issue = EventIssue(error)
            return false
        }
    }
}
