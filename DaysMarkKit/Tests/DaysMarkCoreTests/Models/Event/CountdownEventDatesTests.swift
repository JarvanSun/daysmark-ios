//
//  CountdownEventDatesTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct CountdownEventDatesTests {
    @Test
    func initWhenTheWallTimeDoesNotExistThenHasNoUTCOffset() throws {
        // Given / When
        let timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let event = CountdownEvent.mock(
            title: "DST gap",
            year: 2025,
            month: 3,
            day: 9,
            hour: 2,
            minute: 30,
            timeZone: timeZone,
            timeSemantics: .fixedInstant
        )

        // Then
        #expect(event.utcOffsetSecondsAtCreation == nil)
    }

    @Test
    func initWhenTheEndIsBeforeTheStartThenHasNoDaySpan() throws {
        // Given / When
        let timeZone = try #require(TimeZone(secondsFromGMT: 0))
        let event = CountdownEvent.mock(
            title: "Invalid range",
            year: 2027,
            month: 5,
            day: 2,
            timeZone: timeZone,
            endYear: 2027,
            endMonth: 5,
            endDay: 1,
            timeSemantics: .floatingAllDay
        )

        // Then
        #expect(event.rangeCalendarDaySpan == nil)
    }
}
