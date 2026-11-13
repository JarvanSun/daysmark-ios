//
//  ImportedEventWriter.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@MainActor
struct ImportedEventWriter {
    let context: ModelContext
    let now: Date

    private let revisions: EventRevisionWriter

    init(context: ModelContext, now: Date) {
        self.context = context
        self.now = now
        revisions = EventRevisionWriter(context: context)
    }

    func write(_ changes: [ImportedEventChange]) throws {
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())

        try context.transaction {
            for change in changes {
                try apply(change, to: events)
            }
        }
    }

    private func apply(_ change: ImportedEventChange, to events: [CountdownEvent]) throws {
        switch change {
        case .create(let id, let content, let category, let reminder):
            try insert(content, as: id, in: category, reminder: reminder)
        case .update(let eventID, let content):
            guard let event = events.first(where: { $0.id == eventID }) else { return }

            update(event, with: content)
        case .keep(let eventID, let snapshotDigest):
            guard let event = events.first(where: { $0.id == eventID }) else { return }

            event.snapshotDigest = snapshotDigest
            event.updatedAt = now
            revisions.appendContentRevision(for: event, at: now)
        }
    }

    private func insert(
        _ content: ImportedEventContent,
        as id: CountdownEvent.ID,
        in category: BuiltInCategory,
        reminder: ReminderDraft?
    ) throws {
        let event = CountdownEvent(
            id: id,
            title: content.title,
            year: content.date.year,
            month: content.date.month,
            day: content.date.day,
            hour: content.date.hour,
            minute: content.date.minute,
            timeZone: content.timeZone,
            repeatRule: content.repeatRule,
            category: try context.storedCategory(category),
            calendarSystem: content.date.calendarSystem,
            timeSemantics: content.timeSemantics,
            createdAt: now,
            updatedAt: now
        )
        event.targetEra = content.date.era
        event.targetIsLeapMonth = content.date.isLeapMonth
        event.categoryID = category.id
        event.sourceKind = content.sourceKind
        event.snapshotDigest = content.snapshotDigest
        event.conflictFingerprint = EventContentFingerprint(event).rawValue
        context.insert(event)

        if let rule = reminder?.rule(for: event) {
            rule.event = event
            event.reminders = [rule]
            context.insert(rule)
        }

        revisions.appendInitialRevision(for: event, at: now)
    }

    private func update(_ event: CountdownEvent, with content: ImportedEventContent) {
        event.title = content.title
        event.targetYear = content.date.year
        event.targetMonth = content.date.month
        event.targetDay = content.date.day
        event.targetEra = content.date.era
        event.targetIsLeapMonth = content.date.isLeapMonth
        event.targetHour = content.date.hour
        event.targetMinute = content.date.minute
        event.timeSemantics = content.timeSemantics
        event.calendarSystem = content.date.calendarSystem
        event.timeZoneIdentifier = content.timeZone.identifier
        event.repeatRule = content.repeatRule
        event.snapshotDigest = content.snapshotDigest
        event.updatedAt = now
        event.conflictFingerprint = EventContentFingerprint(event).rawValue
        revisions.appendContentRevision(for: event, at: now)
    }
}
