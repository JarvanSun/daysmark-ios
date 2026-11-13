//
//  EventItem.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation
import SwiftUI

struct EventItem: Identifiable {
    let counted: EventDayCount
    let now: Date
    let timeZone: TimeZone
    let locale: Locale

    var id: CountdownEvent.ID { counted.id }

    var direction: DayCount.Direction { counted.dayCount.direction }

    init(_ counted: EventDayCount, at time: CurrentTime) {
        self.counted = counted
        now = time.now
        timeZone = time.timeZone
        locale = time.locale
    }
}

extension EventItem {
    var title: String { counted.event.title }

    var appearance: EventAppearance { EventAppearance(storedKey: counted.event.icon) }

    var tint: DaysMarkColor { direction.tint }

    var countsDown: Bool { direction == .upcoming }

    var phrase: String {
        counted.relativeTimePhrase(at: now, userTimeZone: timeZone, locale: locale).text
    }

    var date: String {
        formattedDate(includesWeekday: false)
    }

    var dateWithWeekday: String {
        formattedDate(includesWeekday: true)
    }

    var accessibilityLabel: String {
        [title, phrase, dateWithWeekday]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    private func formattedDate(includesWeekday: Bool) -> String {
        guard let occurrence = counted.resolvedOccurrenceDate else { return "" }

        let event = counted.event
        let displayTimeZone =
            event.timeSemantics == .fixedInstant ? event.timeZone ?? timeZone : timeZone
        var calendar = Calendar(identifier: event.calendarSystem.identifier)
        calendar.timeZone = displayTimeZone
        let occursThisYear =
            calendar.component(.year, from: occurrence) == calendar.component(.year, from: now)

        let year = occursThisYear ? "" : "y "
        let weekday = includesWeekday ? "EEE " : ""
        let time = event.timeSemantics == .floatingAllDay ? "" : " jm"

        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = calendar
        formatter.timeZone = displayTimeZone
        formatter.setLocalizedDateFormatFromTemplate(year + weekday + "MMM d" + time)

        return formatter.string(from: occurrence)
    }
}
