//
//  ReminderTriggerResolver.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct ReminderTriggerResolver {
    let event: CountdownEvent
    let now: Date
    let userTimeZone: TimeZone
    let occurrenceResolver: EventOccurrenceResolver

    func nextTrigger(
        for rule: ReminderRule
    ) -> (occurrence: EventOccurrence, trigger: ReminderTrigger)? {
        guard var cursor = searchStart(for: rule) else { return nil }

        for _ in 0...1 {
            guard
                let occurrence = occurrenceResolver.nextOccurrence(
                    for: event,
                    now: cursor,
                    userTimeZone: userTimeZone
                ),
                let trigger = trigger(for: rule, at: occurrence)
            else { return nil }

            if trigger.date > now {
                return (occurrence, trigger)
            }

            guard event.repeatRule != .never, let after = instant(after: occurrence) else {
                return nil
            }

            cursor = after
        }

        return nil
    }

    func trigger(for node: SpecialReminderNode, at time: TimeOfDay) -> ReminderTrigger? {
        switch node.kind {
        case .beforeDays: triggerBeforeNextOccurrence(days: node.value, at: time)
        case .elapsedDays: triggerFromFirstStart(.days(node.value), at: time)
        case .anniversaryYears: triggerFromFirstStart(.years(node.value), at: time)
        }
    }
}

// MARK: - ReminderTrigger

struct ReminderTrigger: Equatable, Sendable {
    let date: Date
    let components: DateComponents
}

// MARK: - Private

private extension ReminderTriggerResolver {
    enum NodeOffset {
        case days(Int)
        case years(Int)
    }

    func searchStart(for rule: ReminderRule) -> Date? {
        switch rule.kind {
        case .allDayOffsetAtTime:
            var calendar = Calendar(identifier: event.calendarSystem.identifier)
            calendar.timeZone = userTimeZone

            return calendar.date(byAdding: .day, value: max(0, rule.daysBefore), to: now)
        case .exactTimeOffset:
            guard let minutesBefore = rule.minutesBefore, minutesBefore >= 0 else { return nil }

            return now.addingTimeInterval(TimeInterval(minutesBefore * 60))
        }
    }

    func trigger(for rule: ReminderRule, at occurrence: EventOccurrence) -> ReminderTrigger? {
        switch rule.kind {
        case .allDayOffsetAtTime: allDayTrigger(for: rule, at: occurrence)
        case .exactTimeOffset: exactTimeTrigger(for: rule, at: occurrence)
        }
    }

    func allDayTrigger(for rule: ReminderRule, at occurrence: EventOccurrence)
        -> ReminderTrigger?
    {
        let calendarSystem = occurrence.start.calendarSystem
        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = userTimeZone

        let fireDay = calendar.date(
            byAdding: .day,
            value: -rule.daysBefore,
            to: occurrence.startDate
        )

        guard let fireDay else { return nil }

        var components = calendar.dateComponents([.era, .year, .month, .day], from: fireDay)
        components.hour = rule.hour
        components.minute = rule.minute

        guard let date = calendar.strictDate(from: components) else { return nil }

        if calendarSystem != .gregorian {
            components.calendar = Calendar(identifier: calendarSystem.identifier)
        }

        return ReminderTrigger(date: date, components: components)
    }

    func exactTimeTrigger(
        for rule: ReminderRule,
        at occurrence: EventOccurrence
    ) -> ReminderTrigger? {
        guard let minutesBefore = rule.minutesBefore, let timeZone = triggerTimeZone else {
            return nil
        }

        let date = occurrence.startDate.addingTimeInterval(-TimeInterval(minutesBefore * 60))

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.timeZone = event.timeSemantics == .floatingLocalTime ? nil : timeZone

        return ReminderTrigger(date: date, components: components)
    }

    func triggerBeforeNextOccurrence(days: Int, at time: TimeOfDay) -> ReminderTrigger? {
        guard let timeZone = triggerTimeZone else { return nil }

        var calendar = Calendar(identifier: event.calendarSystem.identifier)
        calendar.timeZone = timeZone

        guard var searchNow = calendar.date(byAdding: .day, value: days, to: now) else {
            return nil
        }

        for _ in 0...1 {
            guard
                let occurrence = occurrenceResolver.nextOccurrence(
                    for: event,
                    now: searchNow,
                    userTimeZone: userTimeZone
                ),
                let trigger = trigger(
                    anchoredAt: occurrence.startDate,
                    offset: .days(-days),
                    at: time
                )
            else { return nil }

            if trigger.date > now {
                return trigger
            }

            guard event.repeatRule != .never, let after = instant(after: occurrence) else {
                return nil
            }

            searchNow = after
        }

        return nil
    }

    func triggerFromFirstStart(_ offset: NodeOffset, at time: TimeOfDay) -> ReminderTrigger? {
        let firstStart = event.startDateSpecification.resolvedDate(
            semantics: event.timeSemantics,
            eventTimeZone: TimeZone(identifier: event.timeZoneIdentifier),
            userTimeZone: userTimeZone
        )

        guard let firstStart else { return nil }

        return trigger(anchoredAt: firstStart, offset: offset, at: time)
    }

    func trigger(
        anchoredAt anchor: Date,
        offset: NodeOffset,
        at time: TimeOfDay
    ) -> ReminderTrigger? {
        guard let timeZone = triggerTimeZone else { return nil }

        var calendar = Calendar(identifier: event.calendarSystem.identifier)
        calendar.timeZone = timeZone

        guard let shifted = shift(anchor, by: offset, in: calendar) else { return nil }

        var components = calendar.dateComponents([.era, .year, .month, .day], from: shifted)
        components.hour = time.hour
        components.minute = time.minute
        components.timeZone = event.timeSemantics == .fixedInstant ? timeZone : nil

        guard let date = calendar.strictDate(from: components) else { return nil }

        if event.calendarSystem != .gregorian {
            components.calendar = Calendar(identifier: event.calendarSystem.identifier)
        }

        return ReminderTrigger(date: date, components: components)
    }

    func shift(_ anchor: Date, by offset: NodeOffset, in calendar: Calendar) -> Date? {
        switch offset {
        case .days(let days): calendar.date(byAdding: .day, value: days, to: anchor)
        case .years(let years): sameDay(years: years, after: anchor, in: calendar)
        }
    }

    func sameDay(years: Int, after anchor: Date, in calendar: Calendar) -> Date? {
        guard let shifted = calendar.date(byAdding: .year, value: years, to: anchor) else {
            return nil
        }

        let original = calendar.dateComponents([.era, .year, .month, .day], from: anchor)
        let parts = calendar.dateComponents([.era, .year, .month, .day], from: shifted)

        guard parts.era == original.era,
            parts.month == original.month,
            parts.day == original.day,
            (parts.isLeapMonth ?? false) == (original.isLeapMonth ?? false)
        else { return nil }

        return shifted
    }

    var triggerTimeZone: TimeZone? {
        event.timeSemantics == .fixedInstant
            ? TimeZone(identifier: event.timeZoneIdentifier)
            : userTimeZone
    }

    func instant(after occurrence: EventOccurrence) -> Date? {
        let lastDate = occurrence.endDate ?? occurrence.startDate

        guard event.timeSemantics == .floatingAllDay else {
            return lastDate.addingTimeInterval(1)
        }

        var calendar = Calendar(identifier: event.calendarSystem.identifier)
        calendar.timeZone = userTimeZone

        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastDate))
    }
}
