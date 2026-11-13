//
//  EventDateSpecificationMoving.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension EventDateSpecification {
    func moved(
        to date: Date,
        semantics: EventTimeSemantics,
        timeZone: TimeZone
    ) -> EventDateSpecification? {
        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents(
            [.era, .year, .month, .day, .hour, .minute],
            from: date
        )

        guard let year = components.year, let month = components.month, let day = components.day
        else { return nil }

        var result = EventDateSpecification(
            calendarSystem: calendarSystem,
            era: components.era,
            year: year,
            month: month,
            day: day,
            isLeapMonth: components.isLeapMonth ?? false,
            hour: semantics == .floatingAllDay ? nil : hour,
            minute: semantics == .floatingAllDay ? nil : minute
        )

        if semantics == .fixedInstant {
            result.utcOffsetSecondsAtCreation = result.firstMatchingUTCOffset(in: timeZone)
        }

        return result
    }
}
