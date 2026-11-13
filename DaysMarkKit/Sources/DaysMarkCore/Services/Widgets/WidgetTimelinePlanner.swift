//
//  WidgetTimelinePlanner.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/08/01.
//

import Foundation

struct WidgetTimelinePlanner: Sendable {
    private let timeZone: TimeZone
    private let dayCount: Int

    var entryLimit: Int { 48 }

    init(timeZone: TimeZone, dayCount: Int = 7) {
        self.timeZone = timeZone
        self.dayCount = dayCount
    }

    func entryDates(from now: Date, events: [CountdownEvent]) -> [Date] {
        let midnights = entryDates(from: now)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        guard dayCount > 0, let horizon = calendar.date(byAdding: .day, value: dayCount, to: now)
        else { return midnights }

        let changes = EventSorter()
            .counted(events, now: now, userTimeZone: timeZone)
            .filter { $0.event.timeSemantics != .floatingAllDay }
            .flatMap(phraseChanges)
            .filter { $0 > now && $0 <= horizon }

        return Array(Set(midnights + changes).sorted().prefix(entryLimit))
    }

    func entryDates(from now: Date) -> [Date] {
        guard dayCount > 0 else { return [] }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        var dates = [now]
        var cursor = now

        for _ in 1..<dayCount {
            let next = calendar.nextDate(
                after: cursor,
                matching: DateComponents(hour: 0, minute: 0, second: 0),
                matchingPolicy: .nextTime
            )

            guard let next else { break }

            dates.append(next)
            cursor = next
        }

        return dates
    }

    private func phraseChanges(of item: EventDayCount) -> [Date] {
        let start = item.resolvedOccurrenceEndDate == nil ? nil : item.resolvedOccurrenceStartDate
        let afterEnd = item.resolvedOccurrenceEndDate?.addingTimeInterval(1)

        return (targetChanges(of: item) + [start, afterEnd]).compactMap(\.self)
    }

    private func targetChanges(of item: EventDayCount) -> [Date?] {
        guard let target = item.resolvedOccurrenceDate else { return [] }

        var eventCalendar = Calendar(identifier: item.event.calendarSystem.identifier)
        eventCalendar.timeZone =
            item.event.timeSemantics == .fixedInstant ? item.event.timeZone ?? timeZone : timeZone

        let repeatsWithoutEnd =
            item.event.repeatRule != .never && item.resolvedOccurrenceEndDate == nil

        return [
            eventCalendar.startOfDay(for: target),
            repeatsWithoutEnd ? target.addingTimeInterval(1) : nil,
        ]
    }
}
