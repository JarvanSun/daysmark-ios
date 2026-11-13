//
//  EventLifecycle.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import SwiftData

@MainActor
struct EventLifecycle {
    let context: ModelContext

    private let revisions: EventRevisionWriter
    private let focus: FocusSelectionWriter

    init(context: ModelContext) {
        self.context = context
        revisions = EventRevisionWriter(context: context)
        focus = FocusSelectionWriter(context: context)
    }

    var retention: TimeInterval { 30 * 24 * 60 * 60 }

    func softDelete(_ event: CountdownEvent, at date: Date) throws {
        guard event.deletedAt == nil else { return }

        let revision = EventRevision(
            eventID: event.id,
            parentRevisionID: event.currentRevisionID,
            conflictGroupID: event.currentRevisionID ?? revisions.rootConflictGroupID,
            createdAt: date,
            isDeletion: true,
            event: event
        )
        context.insert(revision)
        event.deletedAt = date
        event.deletionRevisionID = revision.id
        event.currentRevisionID = revision.id

        try focus.clearIfSelecting(event.id, at: date)
        try context.save()
    }

    func restore(_ event: CountdownEvent, at date: Date) throws {
        guard event.permanentDeletionRequestedAt == nil,
            let deletionRevisionID = event.deletionRevisionID
        else { return }

        let revision = EventRevision(
            eventID: event.id,
            parentRevisionID: event.currentRevisionID,
            conflictGroupID: event.currentRevisionID ?? revisions.rootConflictGroupID,
            restoredDeletionRevisionID: deletionRevisionID,
            createdAt: date,
            event: event
        )
        context.insert(revision)
        event.deletedAt = nil
        event.deletionRevisionID = nil
        event.currentRevisionID = revision.id

        try context.save()
    }

    func requestPermanentDeletion(
        _ event: CountdownEvent,
        cleaningUp localSources: LocalSourceCleanup,
        at date: Date
    ) throws {
        guard event.permanentDeletionRequestedAt == nil else { return }

        if event.deletedAt == nil {
            try softDelete(event, at: date)
        }

        try localSources.request(for: event.id, at: date)

        do {
            let revision = EventRevision(
                eventID: event.id,
                parentRevisionID: event.currentRevisionID,
                conflictGroupID: event.currentRevisionID ?? revisions.rootConflictGroupID,
                createdAt: date,
                isDeletion: true,
                isPermanentDeletionRequest: true,
                event: event
            )
            context.insert(revision)
            event.permanentDeletionRequestedAt = date
            event.deletionRevisionID = revision.id
            event.currentRevisionID = revision.id
            try focus.clearIfSelecting(event.id, at: date)
            try context.save()
        } catch {
            context.rollback()
            throw error
        }

        try localSources.finish(for: event.id)
    }

    @discardableResult
    func purgeExpired(cleaningUp localSources: LocalSourceCleanup, now: Date) throws -> Int {
        let cutoff = now.addingTimeInterval(-retention)
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
            .filter { $0.deletedAt.map { $0 <= cutoff } == true }
        var count = 0

        for event in events where try revisions.unresolvedRevisionIDs(eventID: event.id).isEmpty {
            try physicallyDelete(event, cleaningUp: localSources, at: now)
            count += 1
        }

        return count
    }

    private func physicallyDelete(
        _ event: CountdownEvent,
        cleaningUp localSources: LocalSourceCleanup,
        at date: Date
    ) throws {
        let eventID = event.id
        try localSources.request(for: eventID, at: date)

        for reminder in try context.fetch(FetchDescriptor<ReminderRule>())
        where reminder.eventID == eventID {
            context.delete(reminder)
        }

        for revision in try context.fetch(FetchDescriptor<EventRevision>())
        where revision.eventID == eventID {
            context.delete(revision)
        }

        let markers = try context.fetch(FetchDescriptor<PermanentDeletionMarker>())

        if !markers.contains(where: { $0.eventID == eventID }) {
            context.insert(
                PermanentDeletionMarker(
                    eventID: eventID,
                    seedIdentifier: event.seedIdentifier,
                    deletedAt: date
                )
            )
        }

        do {
            context.delete(event)
            try context.save()
        } catch {
            context.rollback()
            throw error
        }

        try localSources.finish(for: eventID)
    }
}
