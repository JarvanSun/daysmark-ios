//
//  EventDateSpecification.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation

public struct EventDateSpecification: Codable, Equatable, Sendable {
    public var calendarSystem: EventCalendarSystem
    public var era: Int?
    public var year: Int
    public var month: Int
    public var day: Int
    public var isLeapMonth: Bool
    public var hour: Int?
    public var minute: Int?

    var utcOffsetSecondsAtCreation: Int?

    init(
        calendarSystem: EventCalendarSystem,
        era: Int? = nil,
        year: Int,
        month: Int,
        day: Int,
        isLeapMonth: Bool = false,
        hour: Int? = nil,
        minute: Int? = nil,
        utcOffsetSecondsAtCreation: Int? = nil
    ) {
        self.calendarSystem = calendarSystem
        self.era = era
        self.year = year
        self.month = month
        self.day = day
        self.isLeapMonth = isLeapMonth
        self.hour = hour
        self.minute = minute
        self.utcOffsetSecondsAtCreation = utcOffsetSecondsAtCreation
    }

    public func strictDate(
        in timeZone: TimeZone,
        matchingUTCOffset preferredUTCOffset: Int? = nil
    ) -> Date? {
        guard calendarSystem != .chinese || era != nil else { return nil }

        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = timeZone

        let candidate =
            switch preferredUTCOffset {
            case let offset?:
                wallClockDateAtGMT.map { $0.addingTimeInterval(-TimeInterval(offset)) }
            case nil: calendar.date(from: components(in: calendar))
            }

        guard let candidate else { return nil }

        var validationCalendar = calendar

        if let storedOffsetZone = preferredUTCOffset.flatMap({ TimeZone(secondsFromGMT: $0) }) {
            validationCalendar.timeZone = storedOffsetZone
        }

        guard isSameMoment(as: candidate, in: validationCalendar) else { return nil }

        return candidate
    }

    public func resolvedDate(
        semantics: EventTimeSemantics,
        eventTimeZone: TimeZone?,
        userTimeZone: TimeZone
    ) -> Date? {
        switch semantics {
        case .floatingAllDay:
            guard hour == nil, minute == nil else { return nil }

            return strictDate(in: userTimeZone)
        case .fixedInstant:
            guard let eventTimeZone, let utcOffsetSecondsAtCreation, hour != nil, minute != nil
            else { return nil }

            return strictDate(in: eventTimeZone, matchingUTCOffset: utcOffsetSecondsAtCreation)
        case .floatingLocalTime:
            guard hour != nil, minute != nil else { return nil }

            return strictDate(in: userTimeZone)
        }
    }

    func firstMatchingUTCOffset(in timeZone: TimeZone) -> Int? {
        guard hour != nil, minute != nil, let wallClockAnchor = wallClockDateAtGMT else {
            return nil
        }

        var offsets = Set<Int>()

        for hourDelta in stride(from: -72, through: 72, by: 6) {
            offsets.insert(
                timeZone.secondsFromGMT(
                    for: wallClockAnchor.addingTimeInterval(TimeInterval(hourDelta * 60 * 60))
                )
            )
        }

        var namedCalendar = Calendar(identifier: calendarSystem.identifier)
        namedCalendar.timeZone = timeZone
        let matches = offsets.compactMap { offset -> (date: Date, offset: Int)? in
            let candidate = wallClockAnchor.addingTimeInterval(-TimeInterval(offset))

            guard isSameMoment(as: candidate, in: namedCalendar) else { return nil }

            return (candidate, offset)
        }

        return matches.min { $0.date < $1.date }?.offset
    }
}

// MARK: - Private

private extension EventDateSpecification {
    var wallClockDateAtGMT: Date? {
        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = .gmt

        return calendar.date(from: components(in: calendar))
    }

    func components(in calendar: Calendar) -> DateComponents {
        var components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            era: era,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )
        components.isLeapMonth = isLeapMonth

        return components
    }

    func isSameMoment(as date: Date, in calendar: Calendar) -> Bool {
        let roundTrip = calendar.dateComponents(
            [.era, .year, .month, .day, .hour, .minute],
            from: date
        )

        return roundTrip.year == year
            && roundTrip.month == month
            && roundTrip.day == day
            && (era == nil || roundTrip.era == era)
            && (hour == nil || roundTrip.hour == hour)
            && (minute == nil || roundTrip.minute == minute)
            && (roundTrip.isLeapMonth ?? false) == isLeapMonth
    }
}
