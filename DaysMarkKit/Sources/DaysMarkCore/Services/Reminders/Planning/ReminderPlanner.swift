//
//  ReminderPlanner.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation

struct ReminderPlanner: Sendable {
    private let occurrenceResolver = EventOccurrenceResolver()
    private let sorter = EventSorter()

    var pendingRequestLimit: Int { 64 }

    @MainActor
    func plan(
        for events: [CountdownEvent],
        now: Date,
        userTimeZone: TimeZone,
        focusedEventID: UUID?
    ) -> [PlannedReminder] {
        let focusEventID = sorter.focus(
            in: events,
            now: now,
            userTimeZone: userTimeZone,
            focusedEventID: focusedEventID
        )?.event.id

        let planned = events.flatMap {
            ordinaryReminders(for: $0, now: now, userTimeZone: userTimeZone)
                + specialNodeReminders(for: $0, now: now, userTimeZone: userTimeZone)
        }

        return Array(
            planned
                .sorted { order(of: $0, focus: focusEventID) < order(of: $1, focus: focusEventID) }
                .prefix(pendingRequestLimit)
        )
    }

    @MainActor
    func ordinaryReminders(
        for event: CountdownEvent,
        now: Date,
        userTimeZone: TimeZone
    ) -> [PlannedReminder] {
        guard let rules = event.reminders, !rules.isEmpty else { return [] }

        let triggers = triggers(for: event, now: now, userTimeZone: userTimeZone)

        return
            rules
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .compactMap { rule in
                guard let next = triggers.nextTrigger(for: rule) else { return nil }

                let identifier = ReminderIdentifier(
                    eventID: event.id,
                    subject: .rule(rule.id),
                    occurrence: next.occurrence.startDate
                )

                return PlannedReminder(
                    reminder: ScheduledReminder(
                        identifier: identifier.rawValue,
                        title: event.title,
                        body: body(for: rule),
                        userInfo: userInfo(for: event),
                        dateComponents: next.trigger.components
                    ),
                    fireDate: next.trigger.date,
                    eventID: event.id,
                    kind: .ordinary
                )
            }
    }

    private func body(for rule: ReminderRule) -> String {
        switch rule.kind {
        case .allDayOffsetAtTime:
            switch rule.daysBefore {
            case 0: String(localized: "notification.reminder.today", bundle: .module)
            case 1: String(localized: "notification.reminder.tomorrow", bundle: .module)
            default:
                String(
                    localized: "notification.reminder.inDays \(rule.daysBefore)",
                    bundle: .module
                )
            }
        case .exactTimeOffset:
            switch rule.minutesBefore ?? 0 {
            case 0: String(localized: "notification.reminder.atEventTime", bundle: .module)
            case 60: String(localized: "notification.reminder.hourBefore", bundle: .module)
            case 1_440: String(localized: "notification.reminder.dayBefore", bundle: .module)
            case let minutes:
                String(localized: "notification.reminder.minutesBefore \(minutes)", bundle: .module)
            }
        }
    }

    @MainActor
    func specialNodeReminders(
        for event: CountdownEvent,
        now: Date,
        userTimeZone: TimeZone
    ) -> [PlannedReminder] {
        guard let nodes = event.specialReminderNodes,
            !nodes.isEmpty,
            let hour = event.specialNodeNotificationHour,
            let minute = event.specialNodeNotificationMinute
        else { return [] }

        let triggers = triggers(for: event, now: now, userTimeZone: userTimeZone)
        let time = TimeOfDay(hour: hour, minute: minute)

        return
            nodes
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .compactMap { node in
                guard let trigger = triggers.trigger(for: node, at: time), trigger.date > now else {
                    return nil
                }

                let identifier = ReminderIdentifier(
                    eventID: event.id,
                    subject: .specialNode(node.id),
                    occurrence: trigger.date
                )

                return PlannedReminder(
                    reminder: ScheduledReminder(
                        identifier: identifier.rawValue,
                        title: event.title,
                        body: body(for: node),
                        userInfo: userInfo(for: event),
                        dateComponents: trigger.components
                    ),
                    fireDate: trigger.date,
                    eventID: event.id,
                    kind: .specialNode
                )
            }
    }

    private func body(for node: SpecialReminderNode) -> String {
        switch node.kind {
        case .beforeDays:
            String(localized: "notification.node.before \(node.value)", bundle: .module)
        case .elapsedDays:
            String(localized: "notification.node.elapsed \(node.value)", bundle: .module)
        case .anniversaryYears:
            String(localized: "notification.node.anniversary \(node.value)", bundle: .module)
        }
    }

    func userInfo(for event: CountdownEvent) -> [String: String] {
        var userInfo = [NotificationPayloadKey.eventID.rawValue: event.id.uuidString]
        userInfo[NotificationPayloadKey.deepLink.rawValue] =
            AppRequest.event(event.id).url?.absoluteString

        return userInfo
    }

    private func triggers(
        for event: CountdownEvent,
        now: Date,
        userTimeZone: TimeZone
    ) -> ReminderTriggerResolver {
        ReminderTriggerResolver(
            event: event,
            now: now,
            userTimeZone: userTimeZone,
            occurrenceResolver: occurrenceResolver
        )
    }

    private func order(of planned: PlannedReminder, focus focusEventID: UUID?) -> (
        Date, Int, Int, String
    ) {
        let focusRank = planned.eventID == focusEventID ? 0 : 1

        return (planned.fireDate, focusRank, planned.kind.rawValue, planned.reminder.identifier)
    }
}

// MARK: - PlannedReminder

struct PlannedReminder: Equatable, Sendable {
    let reminder: ScheduledReminder
    let fireDate: Date
    let eventID: UUID
    let kind: Kind
}

extension PlannedReminder {
    enum Kind: Int, Sendable {
        case ordinary
        case specialNode
    }
}
