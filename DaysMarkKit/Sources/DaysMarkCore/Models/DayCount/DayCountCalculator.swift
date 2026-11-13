//
//  DayCountCalculator.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation

public struct DayCountCalculator: Sendable {
    private let calendar: Calendar

    public init(calendar: Calendar) {
        self.calendar = calendar
    }

    public func dayCount(
        targetDay: DateComponents,
        countsFromDayOne: Bool,
        now: Date,
        userTimeZone: TimeZone
    ) -> DayCount? {
        var calendar = calendar
        calendar.timeZone = userTimeZone

        guard let year = targetDay.year,
            let month = targetDay.month,
            let day = targetDay.day,
            let targetDate = calendar.strictDate(
                from: DateComponents(year: year, month: month, day: day)
            )
        else { return nil }

        return dayCount(to: targetDate, in: calendar, countsFromDayOne: countsFromDayOne, now: now)
    }

    public func dayCount(
        targetDate: Date,
        calendarSystem: EventCalendarSystem,
        countsFromDayOne: Bool,
        now: Date,
        userTimeZone: TimeZone
    ) -> DayCount? {
        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = userTimeZone

        return dayCount(to: targetDate, in: calendar, countsFromDayOne: countsFromDayOne, now: now)
    }

    private func dayCount(
        to targetDate: Date,
        in calendar: Calendar,
        countsFromDayOne: Bool,
        now: Date
    ) -> DayCount? {
        let todayStart = calendar.startOfDay(for: now)
        let targetStart = calendar.startOfDay(for: targetDate)
        let difference = calendar.dateComponents([.day], from: todayStart, to: targetStart).day

        return switch difference {
        case nil: nil
        case 0?: DayCount(days: 0, direction: .today)
        case let days? where days > 0: DayCount(days: days, direction: .upcoming)
        case let days?: DayCount(days: -days + (countsFromDayOne ? 1 : 0), direction: .past)
        }
    }
}
