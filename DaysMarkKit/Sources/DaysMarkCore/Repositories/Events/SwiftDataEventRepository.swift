//
//  SwiftDataEventRepository.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import SwiftData

@MainActor
public final class SwiftDataEventRepository {
    private let container: ModelContainer
    private let localSources: ModelContainer?
    private let refresher: SystemSurfaceRefreshing
    private let storeChanges: StoreChanges
    private let lifecycle: EventLifecycle
    private let now: () -> Date
    private let timeZone: () -> TimeZone

    public init(
        container: ModelContainer,
        localSources: ModelContainer?,
        refresher: SystemSurfaceRefreshing,
        storeChanges: StoreChanges,
        now: @escaping () -> Date,
        timeZone: @escaping () -> TimeZone
    ) {
        self.container = container
        self.localSources = localSources
        self.refresher = refresher
        self.storeChanges = storeChanges
        lifecycle = EventLifecycle(context: container.mainContext)
        self.now = now
        self.timeZone = timeZone
    }

    private var context: ModelContext { container.mainContext }
}

// MARK: - EventRepository

extension SwiftDataEventRepository: EventRepository {
    public func changes() -> AsyncStream<Void> {
        storeChanges.stream()
    }

    public func events() throws(EventError) -> [CountdownEvent] {
        try fetch(FetchDescriptor<CountdownEvent>())
    }

    public func focusSelections() throws(EventError) -> [FocusSelection] {
        try fetch(FetchDescriptor<FocusSelection>())
    }

    public func focusSelectionRevisions() throws(EventError) -> [FocusSelectionRevision] {
        try fetch(FetchDescriptor<FocusSelectionRevision>())
    }

    public func permanentDeletionMarkers() throws(EventError) -> [PermanentDeletionMarker] {
        try fetch(FetchDescriptor<PermanentDeletionMarker>())
    }

    @discardableResult
    public func save(_ draft: EventDraft, replacing id: CountdownEvent.ID?) throws(EventError)
        -> CountdownEvent.ID
    {
        let drafts = EventDraftWriter(context: context, now: now())

        return try write {
            switch id {
            case let id?:
                let event = try context.event(withID: id)
                try drafts.update(event, with: draft, superseding: [])

                return event.id
            case nil:
                return try drafts.create(from: draft).id
            }
        }
    }

    public func delete(eventID: UUID) throws(EventError) {
        try write {
            try lifecycle.softDelete(context.event(withID: eventID), at: now())
        }
    }

    public func restore(eventID: UUID) throws(EventError) {
        try write {
            try lifecycle.restore(context.event(withID: eventID), at: now())
        }
    }

    public func permanentlyDelete(eventID: UUID) throws(EventError) {
        guard let localSources else { throw .localStoreUnavailable }

        try write {
            let event = try context.event(withID: eventID)

            guard event.deletedAt != nil, event.permanentDeletionRequestedAt == nil else {
                throw EventError.eventUnavailable
            }

            try lifecycle.requestPermanentDeletion(
                event,
                cleaningUp: LocalSourceCleanup(context: localSources.mainContext),
                at: now()
            )
        }
    }

    public func setFocus(eventID: UUID?) throws(EventError) {
        try write {
            try FocusSelectionWriter(context: context).select(eventID, at: now())
        }
    }

    public func conflictVersions(of eventID: CountdownEvent.ID) throws(EventError)
        -> [EventConflictVersion]
    {
        let conflicts = EventConflicts(context: context, now: now(), timeZone: timeZone())

        do {
            return try conflicts.versions(of: eventID)
        } catch {
            throw EventError(error)
        }
    }

    public func resolveConflict(eventID: UUID, keeping versionID: UUID) throws(EventError) {
        let event = try fetch(FetchDescriptor<CountdownEvent>()).first { $0.id == eventID }

        guard let event else { throw .eventUnavailable }

        let versions = try conflictVersions(of: eventID)

        guard let chosen = versions.first(where: { $0.id == versionID }) else { return }

        let drafts = EventDraftWriter(context: context, now: now())

        try write {
            try drafts.update(event, with: chosen.draft, superseding: versions.map(\.id))
        }
    }

    public func seed(_ seeds: [EventSeed]) throws(EventError) {
        try write {
            try EventSeedWriter(context: context, now: now()).seed(seeds)
        }
    }

    public func write(_ changes: [ImportedEventChange]) throws(EventError) {
        try write {
            try ImportedEventWriter(context: context, now: now()).write(changes)
        }
    }

    public func moveEvents(
        from categoryID: EventCategory.ID,
        to replacementID: EventCategory.ID
    ) throws(EventError) {
        do {
            try recategorize(from: categoryID, to: replacementID)
        } catch {
            throw EventError(error)
        }
    }
}

// MARK: - Private

private extension SwiftDataEventRepository {
    func fetch<Model: PersistentModel>(_ descriptor: FetchDescriptor<Model>) throws(EventError)
        -> [Model]
    {
        do {
            return try context.fetch(descriptor)
        } catch {
            throw EventError(error)
        }
    }

    func write<Value>(_ change: () throws -> Value) throws(EventError) -> Value {
        do {
            let value = try change()
            try context.save()
            refresher.refresh()

            return value
        } catch {
            context.rollback()
            throw EventError(error)
        }
    }

    func recategorize(from categoryID: EventCategory.ID, to replacementID: EventCategory.ID) throws
    {
        let categories = try context.fetch(FetchDescriptor<EventCategory>())

        guard let replacement = categories.first(where: { $0.id == replacementID }) else {
            throw EventError.storeFailure
        }

        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
            .filter { $0.categoryID == categoryID || $0.category?.id == categoryID }
        let revisions = EventRevisionWriter(context: context)

        for event in events {
            event.categoryID = replacement.id
            event.category = replacement
            revisions.appendContentRevision(for: event, at: now())
        }
    }
}
