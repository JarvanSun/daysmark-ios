//
//  EventSorter.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation

public struct EventSorter: Sendable {
    private let calculator = DayCountCalculator(calendar: Calendar(identifier: .gregorian))
    private let occurrenceResolver = EventOccurrenceResolver()

    public init() {}

    public func sorted(
        _ events: [CountdownEvent],
        now: Date,
        userTimeZone: TimeZone
    ) -> [EventDayCount] {
        ordered(counted(events, now: now, userTimeZone: userTimeZone))
    }

    public func counted(
        _ events: [CountdownEvent],
        now: Date,
        userTimeZone: TimeZone
    ) -> [EventDayCount] {
        events.compactMap { event in
            guard
                let resolved = occurrenceResolver.nextOccurrence(
                    for: event,
                    now: now,
                    userTimeZone: userTimeZone
                )
            else { return nil }

            let targetDate = resolved.referenceDate(
                now: now,
                semantics: event.timeSemantics,
                userTimeZone: userTimeZone
            )
            var calendar = Calendar(identifier: event.calendarSystem.identifier)
            calendar.timeZone = userTimeZone
            let occurrence = calendar.dateComponents(
                [.era, .year, .month, .day, .hour, .minute],
                from: targetDate
            )

            return calculator.dayCount(
                targetDate: targetDate,
                calendarSystem: event.calendarSystem,
                countsFromDayOne: event.countsFromDayOne,
                now: now,
                userTimeZone: userTimeZone
            ).map {
                EventDayCount(
                    event: event,
                    dayCount: $0,
                    occurrence: occurrence,
                    resolvedOccurrenceStartDate: resolved.startDate,
                    resolvedOccurrenceEndDate: resolved.endDate,
                    resolvedOccurrenceDate: targetDate
                )
            }
        }
    }

    public func effectiveFilter(_ selected: UUID?, in categories: [EventCategory]) -> UUID? {
        guard let selected, categories.contains(where: { $0.id == selected }) else { return nil }

        return selected
    }

    public func ordered(_ counted: [EventDayCount]) -> [EventDayCount] {
        counted.sorted { lhs, rhs in
            if lhs.dayCount.direction != rhs.dayCount.direction {
                return sortRank(lhs.dayCount.direction) < sortRank(rhs.dayCount.direction)
            }
            if lhs.dayCount.days != rhs.dayCount.days {
                return lhs.dayCount.days < rhs.dayCount.days
            }

            let titleOrder = lhs.event.title.localizedStandardCompare(rhs.event.title)
            if titleOrder != .orderedSame { return titleOrder == .orderedAscending }
            return lhs.event.id.uuidString < rhs.event.id.uuidString
        }
    }

    func focus(
        in events: [CountdownEvent],
        now: Date,
        userTimeZone: TimeZone,
        focusedEventID: UUID?
    ) -> EventDayCount? {
        focus(
            among: counted(events, now: now, userTimeZone: userTimeZone),
            focusedEventID: focusedEventID
        )
    }

    public func focus(among counted: [EventDayCount], focusedEventID: UUID?) -> EventDayCount? {
        let byDistance = counted.sorted { lhs, rhs in
            if lhs.dayCount.days != rhs.dayCount.days {
                return lhs.dayCount.days < rhs.dayCount.days
            }
            if lhs.dayCount.direction != rhs.dayCount.direction {
                return sortRank(lhs.dayCount.direction) < sortRank(rhs.dayCount.direction)
            }
            let titleOrder = lhs.event.title.localizedStandardCompare(rhs.event.title)
            if titleOrder != .orderedSame { return titleOrder == .orderedAscending }
            return lhs.event.id.uuidString < rhs.event.id.uuidString
        }
        return focusedEventID.flatMap { id in byDistance.first { $0.id == id } }
            ?? byDistance.first
    }

    private func sortRank(_ direction: DayCount.Direction) -> Int {
        switch direction {
        case .today: 0
        case .upcoming: 1
        case .past: 2
        }
    }
}
