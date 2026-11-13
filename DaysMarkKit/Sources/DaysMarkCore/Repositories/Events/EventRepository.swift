//
//  EventRepository.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

@MainActor
public protocol EventRepository: AnyObject, Sendable {
    func changes() -> AsyncStream<Void>

    func events() throws(EventError) -> [CountdownEvent]

    func focusSelections() throws(EventError) -> [FocusSelection]

    func focusSelectionRevisions() throws(EventError) -> [FocusSelectionRevision]

    func permanentDeletionMarkers() throws(EventError) -> [PermanentDeletionMarker]

    @discardableResult
    func save(_ draft: EventDraft, replacing id: CountdownEvent.ID?) throws(EventError)
        -> CountdownEvent.ID

    func delete(eventID: UUID) throws(EventError)

    func restore(eventID: UUID) throws(EventError)

    func permanentlyDelete(eventID: UUID) throws(EventError)

    func setFocus(eventID: UUID?) throws(EventError)

    func conflictVersions(of eventID: CountdownEvent.ID) throws(EventError)
        -> [EventConflictVersion]

    func resolveConflict(eventID: UUID, keeping versionID: UUID) throws(EventError)

    func seed(_ seeds: [EventSeed]) throws(EventError)

    func write(_ changes: [ImportedEventChange]) throws(EventError)

    func moveEvents(from categoryID: EventCategory.ID, to replacementID: EventCategory.ID)
        throws(EventError)
}
