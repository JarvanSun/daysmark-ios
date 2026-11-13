//
//  RecentlyDeletedViewModel.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class RecentlyDeletedViewModel {
    var isSelecting = false
    var selection: Set<CountdownEvent.ID> = []

    private let highlightedEventID: CountdownEvent.ID?
    private let repository: EventRepository

    private(set) var content = RecentlyDeletedContent()
    private(set) var issue: RecentlyDeletedIssue?

    var title: LocalizedStringResource {
        isSelecting
            ? LocalizedStringResource(
                "settings.recentlyDeleted.selection.count \(selection.count)",
                bundle: .module
            )
            : LocalizedStringResource("settings.recentlyDeleted.title", bundle: .module)
    }

    init(highlightedEventID: CountdownEvent.ID?, repository: EventRepository) {
        self.highlightedEventID = highlightedEventID
        self.repository = repository
    }

    func observeStore() async {
        reload()

        for await _ in repository.changes() {
            reload()
        }
    }

    func reload() {
        do {
            content = RecentlyDeletedContent(rows: try rows(from: repository.events()))
        } catch {
            issue = RecentlyDeletedIssue(error)
        }
    }

    private func rows(from events: [CountdownEvent]) -> [RecentlyDeletedContent.Row] {
        events
            .filter { $0.permanentDeletionRequestedAt == nil }
            .compactMap { event in
                event.deletedAt.map {
                    RecentlyDeletedContent.Row(
                        id: event.id,
                        title: event.title,
                        deletedAt: $0,
                        isHighlighted: event.id == highlightedEventID
                    )
                }
            }
            .sorted { $0.deletedAt > $1.deletedAt }
    }

    func restore(_ id: CountdownEvent.ID) {
        perform(try repository.restore(eventID: id))
    }

    func deletePermanently(_ id: CountdownEvent.ID) {
        perform(try repository.permanentlyDelete(eventID: id))
    }

    func startSelecting() {
        isSelecting = true
    }

    func finishSelecting() {
        selection = []
        isSelecting = false
    }

    func selectAll() {
        selection = content.rowIDs
    }

    func deleteSelectionPermanently() {
        let ids = selection.intersection(content.rowIDs)
        var failed: Set<CountdownEvent.ID> = []

        for id in ids where !perform(try repository.permanentlyDelete(eventID: id)) {
            failed.insert(id)
        }

        selection = failed
        issue = failed.isEmpty ? nil : .batchFailed(count: failed.count)
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
            issue = RecentlyDeletedIssue(error)
            return false
        }
    }
}
