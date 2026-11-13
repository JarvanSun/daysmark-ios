//
//  EventOccurrence.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct EventOccurrence: Equatable, Sendable {
    public let start: EventDateSpecification
    public let end: EventDateSpecification?
    public let startDate: Date
    public let endDate: Date?

    public func referenceDate(now: Date, semantics: EventTimeSemantics, userTimeZone: TimeZone)
        -> Date
    {
        guard let endDate else { return startDate }
        switch semantics {
        case .floatingAllDay:
            var calendar = Calendar(identifier: start.calendarSystem.identifier)
            calendar.timeZone = userTimeZone
            return calendar.startOfDay(for: now) < calendar.startOfDay(for: startDate)
                ? startDate
                : endDate
        case .fixedInstant, .floatingLocalTime:
            return now < startDate ? startDate : endDate
        }
    }
}
