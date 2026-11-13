//
//  EventSeedWriter.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@MainActor
struct EventSeedWriter {
    let context: ModelContext
    let now: Date

    func seed(_ seeds: [EventSeed]) throws {
        let revisions = EventRevisionWriter(context: context)
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
        let markers = try context.fetch(FetchDescriptor<PermanentDeletionMarker>())

        try context.transaction {
            for seed in seeds where !isUsed(seed, by: events, or: markers) {
                let event = try insert(seed)
                revisions.appendInitialRevision(for: event, at: now)
            }
        }
    }

    private func isUsed(
        _ seed: EventSeed,
        by events: [CountdownEvent],
        or markers: [PermanentDeletionMarker]
    ) -> Bool {
        events.contains { $0.id == seed.id || $0.seedIdentifier == seed.identifier }
            || markers.contains { $0.eventID == seed.id || $0.seedIdentifier == seed.identifier }
    }

    private func insert(_ seed: EventSeed) throws -> CountdownEvent {
        let event = seed.event(createdAt: now)
        event.category = try context.storedCategory(seed.category)
        event.categoryID = seed.category.id
        event.sourceKind = .seeded

        let rules = seed.reminders.map { $0.rule(for: event) }

        if !rules.isEmpty {
            event.reminders = rules
        }

        for rule in rules {
            rule.event = event
        }

        context.insert(event)

        return event
    }
}

public struct EventSeed: Sendable {
    let id: UUID
    let identifier: String
    let title: String
    let date: EventDateSpecification
    let timeZone: TimeZone
    let repeatRule: RepeatRule
    let category: BuiltInCategory
    let reminders: [ReminderDraft]

    func event(createdAt date: Date) -> CountdownEvent {
        let event = CountdownEvent(
            id: id,
            recordID: id,
            title: title,
            year: self.date.year,
            month: self.date.month,
            day: self.date.day,
            timeZone: timeZone,
            repeatRule: repeatRule,
            seedIdentifier: identifier,
            calendarSystem: self.date.calendarSystem,
            createdAt: date,
            updatedAt: date
        )
        event.targetEra = self.date.era
        event.targetIsLeapMonth = self.date.isLeapMonth

        return event
    }
}
