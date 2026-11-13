//
//  EventDraftWriter.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/04.
//

import Foundation
import SwiftData

@MainActor
struct EventDraftWriter {
    let context: ModelContext
    let now: Date

    private let revisions: EventRevisionWriter

    init(context: ModelContext, now: Date) {
        self.context = context
        self.now = now
        revisions = EventRevisionWriter(context: context)
    }

    func create(from draft: EventDraft) throws -> CountdownEvent {
        guard !draft.trimmedTitle.isEmpty else { throw EventError.emptyTitle }
        guard draft.isValid, let target = draft.targetDateSpecification else {
            throw EventError.invalidDraft
        }

        let categorySelection = try categorySelection(for: draft.categoryID)
        let event = CountdownEvent(
            title: draft.trimmedTitle,
            year: target.year,
            month: target.month,
            day: target.day,
            hour: target.hour,
            minute: target.minute,
            timeZone: draft.timeZone,
            countsFromDayOne: draft.countsFromDayOne,
            icon: draft.icon,
            repeatRule: draft.repeatRule,
            repeatInterval: draft.repeatInterval,
            repeatUnit: draft.repeatUnit,
            category: categorySelection.projection,
            calendarSystem: draft.calendarSystem,
            timeSemantics: draft.timeSemantics,
            createdAt: now,
            updatedAt: now
        )
        event.categoryID = categorySelection.stableID
        event.isSpotlightHidden = draft.isSpotlightHidden

        context.insert(event)
        try applyDates(of: draft, to: event)
        applyChildRecords(of: draft, to: event)
        revisions.appendInitialRevision(for: event, at: now)

        return event
    }

    func update(_ event: CountdownEvent, with draft: EventDraft, superseding: [UUID]) throws {
        guard !draft.trimmedTitle.isEmpty else { throw EventError.emptyTitle }
        guard draft.isValid else { throw EventError.invalidDraft }
        guard event.permanentDeletionRequestedAt == nil else {
            throw EventError.permanentlyDeleted
        }
        guard event.deletedAt == nil else { throw EventError.inRecentlyDeleted }

        event.title = draft.trimmedTitle
        try applyDates(of: draft, to: event)
        event.countsFromDayOne = draft.countsFromDayOne
        event.repeatRule = draft.repeatRule
        event.repeatInterval = draft.repeatInterval
        event.repeatUnit = draft.repeatUnit
        event.icon = draft.icon
        event.isSpotlightHidden = draft.isSpotlightHidden

        let categorySelection = try categorySelection(for: draft.categoryID)
        event.category = categorySelection.projection
        event.categoryID = categorySelection.stableID

        applyChildRecords(of: draft, to: event)

        event.updatedAt = now
        revisions.appendContentRevision(
            for: event,
            at: now,
            parentRevisionID: superseding.isEmpty ? draft.baseRevisionID : nil,
            superseding: superseding
        )
    }
}

// MARK: - Private

private extension EventDraftWriter {
    func categorySelection(
        for requestedID: UUID?
    ) throws -> (stableID: UUID, projection: EventCategory) {
        let important = try importantCategory()

        guard let requestedID else { return (important.id, important) }

        let categories = try context.fetch(FetchDescriptor<EventCategory>())
        let active = categories.first { $0.id == requestedID && $0.deletedAt == nil }
        let isDeleted = categories.contains { $0.id == requestedID && $0.deletedAt != nil }

        return switch (active, isDeleted) {
        case (let active?, _): (requestedID, active)
        case (nil, true): (important.id, important)
        case (nil, false): (requestedID, important)
        }
    }

    func importantCategory() throws -> EventCategory {
        let categories = try context.fetch(FetchDescriptor<EventCategory>())
        let stored = categories.first {
            $0.id == BuiltInCategory.important.id && $0.deletedAt == nil
        }

        guard let stored else {
            let important = EventCategory(builtIn: .important)
            context.insert(important)

            return important
        }

        return stored
    }

    func applyDates(of draft: EventDraft, to event: CountdownEvent) throws {
        guard let start = draft.targetDateSpecification else { throw EventError.invalidDraft }

        event.calendarSystem = draft.calendarSystem
        event.timeSemantics = draft.timeSemantics
        event.targetEra = start.era
        event.targetYear = start.year
        event.targetMonth = start.month
        event.targetDay = start.day
        event.targetIsLeapMonth = start.isLeapMonth
        event.targetHour = start.hour
        event.targetMinute = start.minute
        event.utcOffsetSecondsAtCreation = start.utcOffsetSecondsAtCreation
        event.timeZoneIdentifier = draft.timeZone.identifier

        guard let end = draft.endDateSpecification else {
            event.endEra = nil
            event.endYear = nil
            event.endMonth = nil
            event.endDay = nil
            event.endIsLeapMonth = false
            event.endHour = nil
            event.endMinute = nil
            event.endUTCOffsetSecondsAtCreation = nil
            event.rangeCalendarDaySpan = nil
            event.rangeDurationSeconds = nil
            return
        }
        guard let range = draft.rangeMeasure else { throw EventError.invalidDraft }

        event.endEra = end.era
        event.endYear = end.year
        event.endMonth = end.month
        event.endDay = end.day
        event.endIsLeapMonth = end.isLeapMonth
        event.endHour = end.hour
        event.endMinute = end.minute
        event.endUTCOffsetSecondsAtCreation = end.utcOffsetSecondsAtCreation

        switch range {
        case .calendarDays(let days):
            event.rangeCalendarDaySpan = days
            event.rangeDurationSeconds = nil
        case .duration(let seconds):
            event.rangeCalendarDaySpan = nil
            event.rangeDurationSeconds = seconds
        }
    }

    func applyChildRecords(of draft: EventDraft, to event: CountdownEvent) {
        applyReminders(draft.reminders, to: event)
        applySpecialReminderNodes(
            draft.specialReminderNodes,
            notificationMinuteOfDay: draft.specialNodeNotificationMinuteOfDay,
            to: event
        )
    }

    func applyReminders(_ drafts: [ReminderDraft], to event: CountdownEvent) {
        let existing = event.reminders ?? []
        let draftIDs = Set(drafts.map(\.id))

        for rule in existing where !draftIDs.contains(rule.id) {
            context.delete(rule)
        }

        var byID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for draft in drafts {
            switch byID[draft.id] {
            case let rule?:
                rule.kind = draft.kind
                rule.minutesBefore = draft.minutesBefore
                rule.daysBefore = draft.daysBefore
                rule.hour = draft.hour
                rule.minute = draft.minute
                canonicalize(rule, for: event)
            case nil:
                let rule = ReminderRule(
                    id: draft.id,
                    eventID: event.id,
                    kind: draft.kind,
                    minutesBefore: draft.minutesBefore,
                    daysBefore: draft.daysBefore,
                    hour: draft.hour,
                    minute: draft.minute
                )
                rule.event = event
                canonicalize(rule, for: event)
                context.insert(rule)
                byID[draft.id] = rule
            }
        }
    }

    func canonicalize(_ rule: ReminderRule, for event: CountdownEvent) {
        switch event.timeSemantics {
        case .floatingAllDay:
            rule.kind = .allDayOffsetAtTime
            rule.minutesBefore = nil
        case .fixedInstant, .floatingLocalTime:
            rule.kind = .exactTimeOffset
            rule.minutesBefore = max(0, rule.minutesBefore ?? 0)
            rule.daysBefore = 0
            rule.hour = 0
            rule.minute = 0
        }
    }

    func applySpecialReminderNodes(
        _ drafts: [SpecialReminderNodeDraft],
        notificationMinuteOfDay: Int?,
        to event: CountdownEvent
    ) {
        let existing = event.specialReminderNodes ?? []
        let draftIDs = Set(drafts.map(\.id))

        for node in existing where !draftIDs.contains(node.id) {
            context.delete(node)
        }

        var byID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for draft in drafts {
            switch byID[draft.id] {
            case let node?:
                node.kind = draft.kind
                node.value = draft.value
            case nil:
                let node = SpecialReminderNode(
                    id: draft.id,
                    eventID: event.id,
                    kind: draft.kind,
                    value: draft.value
                )
                node.event = event
                context.insert(node)
                byID[draft.id] = node
            }
        }

        switch (drafts.isEmpty, notificationMinuteOfDay.map { min(max($0, 0), 1_439) }) {
        case (true, _):
            event.specialNodeNotificationHour = nil
            event.specialNodeNotificationMinute = nil
        case (false, let minuteOfDay?):
            event.specialNodeNotificationHour = minuteOfDay / 60
            event.specialNodeNotificationMinute = minuteOfDay % 60
        case (false, nil):
            break
        }
    }
}
