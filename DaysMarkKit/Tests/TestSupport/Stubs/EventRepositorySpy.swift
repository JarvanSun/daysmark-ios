//
//  EventRepositorySpy.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

public final class EventRepositorySpy: EventRepository {
    public struct Save: Equatable {
        public let eventID: UUID?
        public let draft: EventDraft

        public init(eventID: UUID?, draft: EventDraft) {
            self.eventID = eventID
            self.draft = draft
        }
    }

    public struct Resolution: Equatable {
        public let eventID: UUID
        public let versionID: UUID

        public init(eventID: UUID, versionID: UUID) {
            self.eventID = eventID
            self.versionID = versionID
        }
    }

    public struct Move: Equatable {
        public let categoryID: EventCategory.ID
        public let replacementID: EventCategory.ID

        public init(categoryID: EventCategory.ID, replacementID: EventCategory.ID) {
            self.categoryID = categoryID
            self.replacementID = replacementID
        }
    }

    public var storedEvents: [CountdownEvent]
    public var storedFocusSelections: [FocusSelection]
    public var storedFocusSelectionRevisions: [FocusSelectionRevision]
    public var storedPermanentDeletionMarkers: [PermanentDeletionMarker]
    public var versions: [EventConflictVersion]
    public var error: EventError?
    public var readError: EventError?

    public private(set) var saves: [Save] = []
    public private(set) var deletedIDs: [UUID] = []
    public private(set) var restoredIDs: [UUID] = []
    public private(set) var permanentlyDeletedIDs: [UUID] = []
    public private(set) var selections: [UUID?] = []
    public private(set) var resolutions: [Resolution] = []
    public private(set) var seeds: [[EventSeed]] = []
    public private(set) var writes: [[ImportedEventChange]] = []
    public private(set) var moves: [Move] = []

    private let failingIDs: Set<UUID>

    public init(
        storedEvents: [CountdownEvent] = [],
        storedFocusSelections: [FocusSelection] = [],
        storedFocusSelectionRevisions: [FocusSelectionRevision] = [],
        storedPermanentDeletionMarkers: [PermanentDeletionMarker] = [],
        versions: [EventConflictVersion] = [],
        failingIDs: Set<UUID> = [],
        error: EventError? = nil,
        readError: EventError? = nil
    ) {
        self.storedEvents = storedEvents
        self.storedFocusSelections = storedFocusSelections
        self.storedFocusSelectionRevisions = storedFocusSelectionRevisions
        self.storedPermanentDeletionMarkers = storedPermanentDeletionMarkers
        self.versions = versions
        self.failingIDs = failingIDs
        self.error = error
        self.readError = readError
    }

    public func changes() -> AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }

    public func events() throws(EventError) -> [CountdownEvent] {
        try failReadIfNeeded()

        return storedEvents
    }

    public func focusSelections() throws(EventError) -> [FocusSelection] {
        try failReadIfNeeded()

        return storedFocusSelections
    }

    public func focusSelectionRevisions() throws(EventError) -> [FocusSelectionRevision] {
        try failReadIfNeeded()

        return storedFocusSelectionRevisions
    }

    public func permanentDeletionMarkers() throws(EventError) -> [PermanentDeletionMarker] {
        try failReadIfNeeded()

        return storedPermanentDeletionMarkers
    }

    public func save(_ draft: EventDraft, replacing id: CountdownEvent.ID?) throws(EventError)
        -> CountdownEvent.ID
    {
        saves.append(Save(eventID: id, draft: draft))
        try failIfNeeded(for: id)

        return id ?? UUID()
    }

    public func delete(eventID: UUID) throws(EventError) {
        deletedIDs.append(eventID)
        try failIfNeeded(for: eventID)
    }

    public func restore(eventID: UUID) throws(EventError) {
        restoredIDs.append(eventID)
        try failIfNeeded(for: eventID)
    }

    public func permanentlyDelete(eventID: UUID) throws(EventError) {
        permanentlyDeletedIDs.append(eventID)
        try failIfNeeded(for: eventID)
    }

    public func setFocus(eventID: UUID?) throws(EventError) {
        selections.append(eventID)
        try failIfNeeded(for: eventID)
    }

    public func conflictVersions(of eventID: CountdownEvent.ID) throws(EventError)
        -> [EventConflictVersion]
    {
        try failReadIfNeeded()

        return versions
    }

    public func resolveConflict(eventID: UUID, keeping versionID: UUID) throws(EventError) {
        resolutions.append(Resolution(eventID: eventID, versionID: versionID))
        try failIfNeeded(for: eventID)
    }

    public func seed(_ seeds: [EventSeed]) throws(EventError) {
        self.seeds.append(seeds)
        try failIfNeeded(for: nil)
    }

    public func write(_ changes: [ImportedEventChange]) throws(EventError) {
        writes.append(changes)
        try failIfNeeded(for: nil)
    }

    public func moveEvents(from categoryID: EventCategory.ID, to replacementID: EventCategory.ID)
        throws(EventError)
    {
        moves.append(Move(categoryID: categoryID, replacementID: replacementID))
        try failIfNeeded(for: nil)
    }
}

private extension EventRepositorySpy {
    func failReadIfNeeded() throws(EventError) {
        if let readError {
            throw readError
        }
    }

    func failIfNeeded(for eventID: UUID?) throws(EventError) {
        guard let error else { return }

        if failingIDs.isEmpty || eventID.map(failingIDs.contains) == true {
            throw error
        }
    }
}
