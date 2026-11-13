//
//  EventRepair.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import SwiftData

@MainActor
struct EventRepair {
    let context: ModelContext

    private let revisions: EventRevisionWriter
    private let focus: FocusSelectionWriter

    init(context: ModelContext) {
        self.context = context
        revisions = EventRevisionWriter(context: context)
        focus = FocusSelectionWriter(context: context)
    }

    func repair(now: Date) throws {
        let categories = try categories()
        let events = try convergedEvents()

        for event in events {
            migrate(event, into: categories, now: now)
        }

        try applyDeletionRevisions(to: events)
        try applyDeletionMarkers(to: events)
        try focus.repair(now: now)

        try context.save()
    }

    private func categories() throws -> Categories {
        let categories = try context.fetch(FetchDescriptor<EventCategory>())
        let activeByID = Dictionary(
            grouping: categories.filter { $0.deletedAt == nil },
            by: \.id
        ).compactMapValues(\.first)

        guard let important = activeByID[BuiltInCategory.important.id] else {
            throw EventError.storeFailure
        }

        return Categories(
            deletedIDs: Set(categories.filter { $0.deletedAt != nil }.map(\.id)),
            activeByID: activeByID,
            important: important
        )
    }

    private func convergedEvents() throws -> [CountdownEvent] {
        let fetchedEvents = try context.fetch(FetchDescriptor<CountdownEvent>())
        var events: [CountdownEvent] = []

        for group in Dictionary(grouping: fetchedEvents, by: \.id).values {
            guard let canonical = group.min(by: { $0.recordID.uuidString < $1.recordID.uuidString })
            else { continue }

            events.append(canonical)

            for duplicate in group where duplicate !== canonical {
                context.delete(duplicate)
            }
        }

        return events
    }

    private func migrate(_ event: CountdownEvent, into categories: Categories, now: Date) {
        switch event.currentRevisionID {
        case nil: adoptRelatedCategory(of: event, from: categories)
        case .some: resolveStoredCategory(of: event, from: categories, now: now)
        }

        for reminder in event.reminders ?? [] {
            reminder.eventID = event.id
        }

        for node in event.specialReminderNodes ?? [] {
            node.eventID = event.id
        }

        revisions.appendInitialRevision(for: event, at: now)
    }

    private func adoptRelatedCategory(of event: CountdownEvent, from categories: Categories) {
        switch (event.category, event.category?.builtInKind) {
        case (_, let builtInKind?):
            event.categoryID = builtInKind.id
            event.category = categories.activeByID[builtInKind.id] ?? categories.important
        case (let relatedCategory?, nil) where relatedCategory.deletedAt == nil:
            event.categoryID = relatedCategory.id
            event.category = relatedCategory
        default:
            event.categoryID = BuiltInCategory.important.id
            event.category = categories.important
        }
    }

    private func resolveStoredCategory(
        of event: CountdownEvent,
        from categories: Categories,
        now: Date
    ) {
        let isDeleted = categories.deletedIDs.contains(event.categoryID)

        switch (isDeleted, categories.activeByID[event.categoryID]) {
        case (true, _):
            event.categoryID = BuiltInCategory.important.id
            event.category = categories.important
            revisions.appendContentRevision(for: event, at: now)
        case (false, let resolved?):
            event.category = resolved
        case (false, nil):
            event.category = categories.important
        }
    }
}

extension EventRepair {
    private struct Categories {
        let deletedIDs: Set<UUID>
        let activeByID: [UUID: EventCategory]
        let important: EventCategory
    }
}
