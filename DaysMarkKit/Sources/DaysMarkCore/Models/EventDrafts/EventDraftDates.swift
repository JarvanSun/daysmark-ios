//
//  EventDraftDates.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension EventDraft {
    var targetDateSpecification: EventDateSpecification? {
        specification(for: targetDate)
    }

    var endDateSpecification: EventDateSpecification? {
        endDate.flatMap(specification(for:))
    }

    var rangeMeasure: EventRangeMeasure? {
        guard let targetDateSpecification, let endDateSpecification else { return nil }

        return EventRangeSpecification(
            start: targetDateSpecification,
            end: endDateSpecification,
            semantics: timeSemantics
        ).measure(eventTimeZone: eventTimeZone, userTimeZone: timeZone)
    }

    var eventTimeZone: TimeZone? {
        timeSemantics == .fixedInstant ? timeZone : nil
    }

    private func specification(for date: Date) -> EventDateSpecification? {
        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents(
            [.era, .year, .month, .day, .hour, .minute],
            from: date
        )

        guard let year = components.year, let month = components.month, let day = components.day
        else { return nil }

        let isTimed = timeSemantics != .floatingAllDay
        var result = EventDateSpecification(
            calendarSystem: calendarSystem,
            era: components.era,
            year: year,
            month: month,
            day: day,
            isLeapMonth: components.isLeapMonth ?? false,
            hour: isTimed ? components.hour : nil,
            minute: isTimed ? components.minute : nil
        )

        if timeSemantics == .fixedInstant {
            result.utcOffsetSecondsAtCreation = result.firstMatchingUTCOffset(in: timeZone)
        }

        return result
    }
}
