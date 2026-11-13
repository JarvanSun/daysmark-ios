//
//  EventDetailViewModel.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class EventDetailViewModel {
    var isChoosingVersion = false

    let time: CurrentTime
    private let eventID: CountdownEvent.ID
    private let events: EventRepository
    private let router: EventsRouting

    private(set) var data = DetailData()
    private(set) var unit: EventDetailUnit = .days
    private(set) var issue: EventIssue?

    var content: DetailContent {
        data.content(of: eventID, unit: unit, at: time)
    }

    init(
        eventID: CountdownEvent.ID,
        events: EventRepository,
        time: CurrentTime,
        router: EventsRouting
    ) {
        self.eventID = eventID
        self.events = events
        self.time = time
        self.router = router
    }

    func observeStore() async {
        reload()

        for await _ in events.changes() {
            reload()
        }
    }

    func reload() {
        do {
            data = try DetailData(
                events: events.events(),
                pinnedEventID: FocusSelectionResolver().selectedEventID(
                    selections: events.focusSelections(),
                    revisions: events.focusSelectionRevisions()
                ),
                conflictVersions: events.conflictVersions(of: eventID)
            )
        } catch {
            issue = EventIssue(error)
        }
    }

    func showNextUnit() {
        guard content.canSwitchUnit else { return }

        unit = unit.next
    }

    func togglePin() {
        perform(try events.setFocus(eventID: content.pinAction.pinnedEventID))
    }

    func edit() {
        router.showEditor(for: .existing(eventID))
    }

    func share() {
        router.showSharing(for: eventID)
    }

    func chooseVersion() {
        isChoosingVersion = true
    }

    func keep(_ versionID: EventConflictVersion.ID) {
        perform(try events.resolveConflict(eventID: eventID, keeping: versionID))
        reload()

        isChoosingVersion = false
    }

    func cancelChoosingVersion() {
        isChoosingVersion = false
    }

    func closeIfDeleted() {
        guard content.isDeleted else { return }

        router.closeDetail(for: eventID)
    }

    func acknowledgeIssue() {
        issue = nil
    }

    private func perform(_ change: @autoclosure () throws(EventError) -> Void) {
        do {
            try change()
            issue = nil
        } catch {
            issue = EventIssue(error)
        }
    }
}
