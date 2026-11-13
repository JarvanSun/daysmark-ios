//
//  EventBrowseRefreshPlanner.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct EventBrowseRefreshPlanner: Sendable {
    public init() {}

    public func nextBoundary(
        after now: Date,
        items: [EventDayCount],
        userTimeZone: TimeZone
    ) -> Date? {
        var candidates = items.flatMap { boundaries(of: $0, after: now) }

        if let nextDay = nextDayBoundary(after: now, userTimeZone: userTimeZone) {
            candidates.append(nextDay)
        }

        return candidates.min()
    }

    private func boundaries(of item: EventDayCount, after now: Date) -> [Date] {
        guard item.event.timeSemantics != .floatingAllDay,
            let start = item.resolvedOccurrenceStartDate
        else { return [] }

        guard let end = item.resolvedOccurrenceEndDate else {
            let afterStart = start.addingTimeInterval(postBoundaryDelay)

            return afterStart > now ? [afterStart] : []
        }

        return [
            start > now ? start : nil,
            end >= now ? end.addingTimeInterval(postBoundaryDelay) : nil,
        ]
        .compactMap { $0 }
    }

    private var postBoundaryDelay: TimeInterval { 1 }

    private func nextDayBoundary(after now: Date, userTimeZone: TimeZone) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = userTimeZone

        return calendar.dateInterval(of: .day, for: now)?.end
    }
}
