//
//  CalendarEventScanner.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import EventKit
import Foundation

@MainActor
struct CalendarEventScanner {
    func scan(now: Date, calendar: Calendar) async throws -> [ImportedDate] {
        let store = EKEventStore()
        try await requestAccess(to: store)

        let events = scanWindows(around: now, calendar: calendar).flatMap { window in
            store.events(
                matching: store.predicateForEvents(
                    withStart: window.start,
                    end: window.end,
                    calendars: nil
                )
            )
        }
        var seen = Set<String>()

        return events.compactMap { event in
            guard let identifier = event.eventIdentifier, seen.insert(identifier).inserted else {
                return nil
            }

            return ImportedDate(
                sourceKind: .calendar,
                sourceIdentifier: identifier,
                title: importTitle(event.title),
                date: event.startDate,
                repeatsYearly: false,
                calendarSystem: .gregorian,
                timeZone: calendar.timeZone,
                includesTime: !event.isAllDay
            )
        }
        .sorted { $0.date < $1.date }
    }

    private func requestAccess(to store: EKEventStore) async throws {
        switch ImportAccess(EKEventStore.authorizationStatus(for: .event)) {
        case .granted:
            break
        case .denied:
            throw ImportError.permissionDenied
        case .undetermined:
            guard try await store.requestFullAccessToEvents() else {
                throw ImportError.permissionDenied
            }
        }
    }

    func scanWindows(around now: Date, calendar: Calendar) -> [DateInterval] {
        guard var start = calendar.date(byAdding: .year, value: -yearsAroundNow, to: now),
            let end = calendar.date(byAdding: .year, value: yearsAroundNow, to: now)
        else { return [] }

        var windows: [DateInterval] = []

        while start < end {
            guard let next = calendar.date(byAdding: .year, value: windowYears, to: start) else {
                break
            }

            let windowEnd = min(next, end)
            windows.append(DateInterval(start: start, end: windowEnd))
            start = windowEnd
        }

        return windows
    }

    private var yearsAroundNow: Int { 20 }

    private var windowYears: Int { 3 }

    func importTitle(_ title: String?) -> String {
        let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return trimmed.isEmpty
            ? String(localized: "import.calendar.untitled", bundle: .module) : trimmed
    }
}
