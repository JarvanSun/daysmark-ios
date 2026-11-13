//
//  ImportedDate.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/04.
//

import Foundation

public struct ImportedDate: Identifiable, Equatable, Sendable {
    public let title: String
    public let date: Date
    public let calendarSystem: EventCalendarSystem
    public let timeZone: TimeZone

    let sourceKind: ImportSourceKind
    let sourceIdentifier: String
    let repeatsYearly: Bool
    let includesTime: Bool

    public var id: String { "\(sourceKind.rawValue):\(sourceIdentifier)" }

    var dateComponents: DateComponents {
        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = timeZone
        let units: Set<Calendar.Component> =
            includesTime
            ? [.era, .year, .month, .day, .hour, .minute]
            : [.era, .year, .month, .day]

        return calendar.dateComponents(units, from: date)
    }

    public init(
        sourceKind: ImportSourceKind,
        sourceIdentifier: String,
        title: String,
        date: Date,
        repeatsYearly: Bool,
        calendarSystem: EventCalendarSystem,
        timeZone: TimeZone,
        includesTime: Bool
    ) {
        self.sourceKind = sourceKind
        self.sourceIdentifier = sourceIdentifier
        self.title = title
        self.date = date
        self.repeatsYearly = repeatsYearly
        self.calendarSystem = calendarSystem
        self.timeZone = timeZone
        self.includesTime = includesTime
    }

    public func formattedDate(locale: Locale) -> String {
        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = timeZone
        let style = Date.FormatStyle(
            date: .abbreviated,
            time: .omitted,
            locale: locale,
            calendar: calendar,
            timeZone: timeZone
        )
        let dateOnly = style.year().month(.abbreviated).day()

        return date.formatted(includesTime ? dateOnly.hour().minute() : dateOnly)
    }
}
