//
//  OccurrenceDateFormat.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/08/01.
//

import Foundation

public struct OccurrenceDateFormat: Sendable {
    private let now: Date
    private let userTimeZone: TimeZone
    private let locale: Locale

    public init(now: Date, userTimeZone: TimeZone, locale: Locale) {
        self.now = now
        self.userTimeZone = userTimeZone
        self.locale = locale
    }

    public func text(for item: EventDayCount) -> String? {
        var calendar = Calendar(identifier: item.event.calendarSystem.identifier)
        calendar.timeZone = userTimeZone

        guard let date = item.resolvedOccurrenceDate else {
            return text(for: item.occurrence, in: calendar)
        }

        let style = Date.FormatStyle(
            date: .abbreviated,
            time: .omitted,
            locale: locale,
            calendar: calendar,
            timeZone: userTimeZone
        )

        return switch isInCurrentYear(date, of: calendar) {
        case true: date.formatted(style.month(.abbreviated).day())
        case false: date.formatted(style.year().month(.abbreviated).day())
        }
    }

    private func text(for occurrence: DateComponents, in calendar: Calendar) -> String? {
        guard let date = calendar.strictDate(from: occurrence) else { return nil }

        return switch isInCurrentYear(date, of: calendar) {
        case true: date.formatted(.dateTime.month(.abbreviated).day())
        case false: date.formatted(.dateTime.year().month(.abbreviated).day())
        }
    }

    private func isInCurrentYear(_ date: Date, of calendar: Calendar) -> Bool {
        calendar.component(.year, from: date) == calendar.component(.year, from: now)
    }
}
