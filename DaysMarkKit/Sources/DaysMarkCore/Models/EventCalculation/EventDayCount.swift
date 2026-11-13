//
//  EventDayCount.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct EventDayCount: Identifiable {
    public let event: CountdownEvent
    public let dayCount: DayCount
    public let occurrence: DateComponents
    public let resolvedOccurrenceStartDate: Date?
    public let resolvedOccurrenceEndDate: Date?
    public let resolvedOccurrenceDate: Date?

    public init(
        event: CountdownEvent,
        dayCount: DayCount,
        occurrence: DateComponents,
        resolvedOccurrenceStartDate: Date? = nil,
        resolvedOccurrenceEndDate: Date? = nil,
        resolvedOccurrenceDate: Date? = nil
    ) {
        self.event = event
        self.dayCount = dayCount
        self.occurrence = occurrence
        self.resolvedOccurrenceStartDate = resolvedOccurrenceStartDate
        self.resolvedOccurrenceEndDate = resolvedOccurrenceEndDate
        self.resolvedOccurrenceDate = resolvedOccurrenceDate
    }

    public var id: UUID { event.id }

    public func relativeTimePhrase(
        at now: Date,
        userTimeZone: TimeZone,
        locale: Locale
    ) -> RelativeTimePhrase {
        let subject = RelativeTimeSubject(
            dayCount: dayCount,
            timeSemantics: event.timeSemantics,
            calendarSystem: event.calendarSystem,
            timeZone: event.timeZone,
            date: resolvedOccurrenceDate,
            rangeStart: resolvedOccurrenceStartDate,
            rangeEnd: resolvedOccurrenceEndDate
        )

        return RelativeTimePhraseRules(now: now, userTimeZone: userTimeZone, locale: locale)
            .phrase(for: subject)
    }
}
