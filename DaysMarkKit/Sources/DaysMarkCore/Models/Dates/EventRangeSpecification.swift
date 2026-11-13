//
//  EventRangeSpecification.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct EventRangeSpecification: Equatable, Sendable {
    var start: EventDateSpecification
    var end: EventDateSpecification
    var semantics: EventTimeSemantics

    func measure(eventTimeZone: TimeZone?, userTimeZone: TimeZone) -> EventRangeMeasure? {
        guard start.calendarSystem == end.calendarSystem,
            let startDate = start.resolvedDate(
                semantics: semantics,
                eventTimeZone: eventTimeZone,
                userTimeZone: userTimeZone
            ),
            let endDate = end.resolvedDate(
                semantics: semantics,
                eventTimeZone: eventTimeZone,
                userTimeZone: userTimeZone
            ),
            endDate >= startDate
        else {
            return nil
        }

        switch semantics {
        case .floatingAllDay:
            var calendar = Calendar(identifier: start.calendarSystem.identifier)
            calendar.timeZone = userTimeZone
            guard let days = calendar.dateComponents([.day], from: startDate, to: endDate).day
            else {
                return nil
            }
            return .calendarDays(days)
        case .fixedInstant, .floatingLocalTime:
            return .duration(endDate.timeIntervalSince(startDate))
        }
    }
}

enum EventRangeMeasure: Equatable, Sendable {
    case calendarDays(Int)
    case duration(TimeInterval)
}
