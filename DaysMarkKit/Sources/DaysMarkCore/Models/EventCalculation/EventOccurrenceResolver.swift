//
//  EventOccurrenceResolver.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation

public struct EventOccurrenceResolver: Sendable {
    public init() {}

    public func nextOccurrence(
        for event: CountdownEvent,
        now: Date,
        userTimeZone: TimeZone
    ) -> EventOccurrence? {
        let start = event.startDateSpecification
        let zones = EventTimeZones(
            event: TimeZone(identifier: event.timeZoneIdentifier),
            user: userTimeZone
        )

        guard let resolutionTimeZone = zones.resolution(for: event.timeSemantics),
            let originalStartDate = start.resolvedDate(
                semantics: event.timeSemantics,
                eventTimeZone: zones.event,
                userTimeZone: zones.user
            )
        else { return nil }

        var calendar = Calendar(identifier: start.calendarSystem.identifier)
        calendar.timeZone = resolutionTimeZone

        switch event.repeatRule {
        case .currentYearStart:
            return currentYearOccurrence(of: event, at: now, calendar: calendar, zones: zones)
        case .never:
            return occurrence(of: event, start: start, startDate: originalStartDate, zones: zones)
        case .yearly, .monthly, .monthlyLastDay, .custom:
            let repetition = EventRepetition(
                event: event,
                start: start,
                startDate: originalStartDate,
                calendar: calendar,
                zones: zones
            )

            return nextOccurrence(of: repetition, at: now)
        }
    }
}

// MARK: - Private

private extension EventOccurrenceResolver {
    func currentYearOccurrence(
        of event: CountdownEvent,
        at now: Date,
        calendar: Calendar,
        zones: EventTimeZones
    ) -> EventOccurrence? {
        guard let yearStart = calendar.dateInterval(of: .year, for: now)?.start,
            let currentStart = event.startDateSpecification.moved(
                to: yearStart,
                semantics: event.timeSemantics,
                timeZone: calendar.timeZone
            )
        else { return nil }

        return occurrence(of: event, start: currentStart, startDate: yearStart, zones: zones)
    }

    func nextOccurrence(of repetition: EventRepetition, at now: Date) -> EventOccurrence? {
        let event = repetition.event
        let zones = repetition.zones
        let elapsed = repetition.estimatedPeriods(until: now)

        for offset in 0...skipAttemptLimit {
            guard let candidate = repetition.start(afterPeriods: elapsed + offset),
                let candidateDate = candidate.resolvedDate(
                    semantics: event.timeSemantics,
                    eventTimeZone: zones.event,
                    userTimeZone: zones.user
                ),
                let occurrence = occurrence(
                    of: event,
                    start: candidate,
                    startDate: candidateDate,
                    zones: zones
                ),
                isCurrentOrFuture(
                    occurrence,
                    now: now,
                    semantics: event.timeSemantics,
                    calendar: repetition.calendar
                )
            else { continue }

            return occurrence
        }

        return nil
    }

    var skipAttemptLimit: Int { 400 }

    func occurrence(
        of event: CountdownEvent,
        start: EventDateSpecification,
        startDate: Date,
        zones: EventTimeZones
    ) -> EventOccurrence? {
        guard let timeZone = zones.resolution(for: event.timeSemantics) else { return nil }

        var calendar = Calendar(identifier: start.calendarSystem.identifier)
        calendar.timeZone = timeZone
        let endDate: Date?

        switch (event.timeSemantics, event.rangeCalendarDaySpan, event.rangeDurationSeconds) {
        case (.floatingAllDay, let span?, _):
            endDate = calendar.date(byAdding: .day, value: span, to: startDate)
        case (.fixedInstant, _, let duration?), (.floatingLocalTime, _, let duration?):
            endDate =
                localTimeEnd(of: event, startDate: startDate, calendar: calendar)
                ?? startDate.addingTimeInterval(duration)
        default:
            return EventOccurrence(start: start, end: nil, startDate: startDate, endDate: nil)
        }

        guard let endDate,
            let end = start.moved(to: endDate, semantics: event.timeSemantics, timeZone: timeZone)
        else { return nil }

        return EventOccurrence(start: start, end: end, startDate: startDate, endDate: endDate)
    }

    func localTimeEnd(of event: CountdownEvent, startDate: Date, calendar: Calendar) -> Date? {
        guard event.timeSemantics == .floatingLocalTime,
            let end = event.endDateSpecification,
            let endHour = end.hour, let endMinute = end.minute,
            let originalStart = event.startDateSpecification.resolvedDate(
                semantics: .floatingLocalTime,
                eventTimeZone: nil,
                userTimeZone: calendar.timeZone
            ),
            let originalEnd = end.resolvedDate(
                semantics: .floatingLocalTime,
                eventTimeZone: nil,
                userTimeZone: calendar.timeZone
            ),
            let dayOffset = calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: originalStart),
                to: calendar.startOfDay(for: originalEnd)
            ).day,
            let endDay = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: calendar.startOfDay(for: startDate)
            )
        else { return nil }

        return calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: endDay)
    }

    func isCurrentOrFuture(
        _ occurrence: EventOccurrence,
        now: Date,
        semantics: EventTimeSemantics,
        calendar: Calendar
    ) -> Bool {
        let lastDate = occurrence.endDate ?? occurrence.startDate

        return switch semantics {
        case .floatingAllDay: calendar.startOfDay(for: lastDate) >= calendar.startOfDay(for: now)
        case .fixedInstant, .floatingLocalTime: lastDate >= now
        }
    }
}
