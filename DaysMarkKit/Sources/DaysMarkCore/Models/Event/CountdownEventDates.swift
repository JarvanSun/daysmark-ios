//
//  CountdownEventDates.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension CountdownEvent {
    public var timeZone: TimeZone? {
        TimeZone(identifier: timeZoneIdentifier)
    }

    public internal(set) var calendarSystem: EventCalendarSystem {
        get { EventCalendarSystem(rawValue: calendarSystemRaw) ?? .gregorian }
        set { calendarSystemRaw = newValue.rawValue }
    }

    public internal(set) var timeSemantics: EventTimeSemantics {
        get { EventTimeSemantics(rawValue: timeSemanticsRaw) ?? .floatingAllDay }
        set { timeSemanticsRaw = newValue.rawValue }
    }

    public var startDateSpecification: EventDateSpecification {
        EventDateSpecification(
            calendarSystem: calendarSystem,
            era: targetEra,
            year: targetYear,
            month: targetMonth,
            day: targetDay,
            isLeapMonth: targetIsLeapMonth,
            hour: targetHour,
            minute: targetMinute,
            utcOffsetSecondsAtCreation: utcOffsetSecondsAtCreation
        )
    }

    var endDateSpecification: EventDateSpecification? {
        guard let endYear, let endMonth, let endDay else { return nil }

        return EventDateSpecification(
            calendarSystem: calendarSystem,
            era: endEra,
            year: endYear,
            month: endMonth,
            day: endDay,
            isLeapMonth: endIsLeapMonth,
            hour: endHour,
            minute: endMinute,
            utcOffsetSecondsAtCreation: endUTCOffsetSecondsAtCreation
        )
    }

    var targetComponents: DateComponents {
        DateComponents(
            timeZone: timeZone,
            year: targetYear,
            month: targetMonth,
            day: targetDay,
            hour: targetHour,
            minute: targetMinute
        )
    }

    var endComponents: DateComponents? {
        guard let endYear, let endMonth, let endDay else { return nil }

        return DateComponents(timeZone: timeZone, year: endYear, month: endMonth, day: endDay)
    }

    func deriveDateState(in timeZone: TimeZone) {
        deriveUTCOffset(in: timeZone)
        deriveAllDayRange(in: timeZone)
    }

    private func deriveUTCOffset(in timeZone: TimeZone) {
        guard timeSemantics == .fixedInstant, let targetHour, let targetMinute else { return }

        let specification = EventDateSpecification(
            calendarSystem: calendarSystem,
            year: targetYear,
            month: targetMonth,
            day: targetDay,
            hour: targetHour,
            minute: targetMinute
        )
        utcOffsetSecondsAtCreation = specification.firstMatchingUTCOffset(in: timeZone)
    }

    private func deriveAllDayRange(in timeZone: TimeZone) {
        guard timeSemantics == .floatingAllDay, let endYear, let endMonth, let endDay else {
            return
        }

        let start = EventDateSpecification(
            calendarSystem: calendarSystem,
            year: targetYear,
            month: targetMonth,
            day: targetDay
        )
        let end = EventDateSpecification(
            calendarSystem: calendarSystem,
            year: endYear,
            month: endMonth,
            day: endDay
        )
        let range = EventRangeSpecification(start: start, end: end, semantics: .floatingAllDay)

        guard
            case .calendarDays(let span)? = range.measure(
                eventTimeZone: nil,
                userTimeZone: timeZone
            ), span >= 0
        else { return }

        rangeCalendarDaySpan = span
    }
}
