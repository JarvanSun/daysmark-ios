//
//  CalendarEventScannerTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct CalendarEventScannerTests {
    @Test
    func scanWindowsThenCoverTwentyYearsEachWayInWindowsOfAtMostThreeYears() throws {
        // Given
        let calendar = Calendar.mockGregorianUTC

        // When
        let windows = CalendarEventScanner().scanWindows(around: .mockNow, calendar: calendar)

        // Then
        let first = try #require(windows.first)
        let last = try #require(windows.last)
        let years = windows.map {
            calendar.dateComponents([.year], from: $0.start, to: $0.end).year ?? 0
        }
        #expect(first.start == calendar.date(byAdding: .year, value: -20, to: .mockNow))
        #expect(last.end == calendar.date(byAdding: .year, value: 20, to: .mockNow))
        #expect(zip(windows, windows.dropFirst()).allSatisfy { $0.end == $1.start })
        #expect(years.allSatisfy { $0 <= 3 })
    }

    @Test(arguments: [
        ("  Conference  ", "Conference"), ("  ", "Calendar event"), (nil, "Calendar event"),
    ])
    func importTitleThenTrimsTheTitleOrNamesAnUntitledEvent(title: String?, expected: String) {
        #expect(CalendarEventScanner().importTitle(title) == expected)
    }
}
