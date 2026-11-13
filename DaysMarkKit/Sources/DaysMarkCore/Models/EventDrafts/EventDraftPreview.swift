//
//  EventDraftPreview.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension EventDraft {
    public func previewEvent(at date: Date) -> CountdownEvent? {
        guard let start = targetDateSpecification else { return nil }

        let event = CountdownEvent(
            title: trimmedTitle,
            year: start.year,
            month: start.month,
            day: start.day,
            hour: start.hour,
            minute: start.minute,
            timeZone: timeZone,
            countsFromDayOne: countsFromDayOne,
            repeatRule: repeatRule,
            repeatInterval: repeatInterval,
            repeatUnit: repeatUnit,
            calendarSystem: calendarSystem,
            timeSemantics: timeSemantics,
            createdAt: date,
            updatedAt: date
        )
        event.targetEra = start.era
        event.targetIsLeapMonth = start.isLeapMonth
        event.utcOffsetSecondsAtCreation = start.utcOffsetSecondsAtCreation

        switch rangeMeasure {
        case .calendarDays(let days): event.rangeCalendarDaySpan = days
        case .duration(let seconds): event.rangeDurationSeconds = seconds
        case nil: break
        }

        return event
    }
}
