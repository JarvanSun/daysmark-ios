//
//  ShareData.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation

struct ShareData {
    var events: [CountdownEvent] = []
    var categories: [EventCategory] = []

    func content(
        of eventID: CountdownEvent.ID,
        includesCategory: Bool,
        at time: CurrentTime
    ) -> EventShareContent? {
        guard let event = events.first(where: { $0.id == eventID && $0.deletedAt == nil }) else {
            return nil
        }

        let counted = EventSorter()
            .counted([event], now: time.now, userTimeZone: time.timeZone)
            .first

        guard let counted, let date = counted.resolvedOccurrenceDate else { return nil }

        let formatter = ShareDateFormatter(
            event: event,
            userTimeZone: time.timeZone,
            locale: time.locale
        )
        let categoryName = categories.first { $0.id == event.categoryID }?.displayName

        return EventShareContent(
            title: event.title,
            relativeTime: counted.relativeTimePhrase(
                at: time.now,
                userTimeZone: time.timeZone,
                locale: time.locale
            ).text,
            absoluteTime: formatter.occurrence(of: counted, on: date),
            calendarName: formatter.calendarName,
            referenceDateText: formatter.reference(to: time.now),
            appearance: EventAppearance(storedKey: event.icon),
            direction: counted.dayCount.direction,
            category: includesCategory ? categoryName : nil
        )
    }
}

private struct ShareDateFormatter {
    let event: CountdownEvent
    let userTimeZone: TimeZone
    let locale: Locale

    var calendarName: String? {
        switch event.calendarSystem {
        case .gregorian: nil
        case .chinese, .islamicUmmAlQura: String(localized: event.calendarSystem.title)
        }
    }

    func occurrence(of counted: EventDayCount, on date: Date) -> String {
        switch (counted.resolvedOccurrenceStartDate, counted.resolvedOccurrenceEndDate) {
        case (.some(let start), .some(let end)):
            String(
                localized: "sharing.card.range \(text(for: start)) \(text(for: end))",
                bundle: .module,
                locale: locale
            )
        default: text(for: date)
        }
    }

    private func text(for date: Date) -> String {
        let timeZone =
            event.timeSemantics == .fixedInstant ? event.timeZone ?? userTimeZone : userTimeZone
        var calendar = Calendar(identifier: event.calendarSystem.identifier)
        calendar.timeZone = timeZone
        let year = event.calendarSystem == .chinese ? "Gy" : "y"
        let time = event.targetHour == nil ? "" : "jm"

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.setLocalizedDateFormatFromTemplate(year + "MMMMd" + time)

        return formatter.string(from: date)
    }

    func reference(to now: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = userTimeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return String(
            localized: "sharing.card.reference \(formatter.string(from: now))",
            bundle: .module,
            locale: locale
        )
    }
}
