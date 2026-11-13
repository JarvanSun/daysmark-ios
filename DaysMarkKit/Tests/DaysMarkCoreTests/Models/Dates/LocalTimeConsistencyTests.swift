//
//  LocalTimeConsistencyTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/10/07.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct LocalTimeConsistencyTests {
    @Test
    func editingInAnotherTimeZoneKeepsTheDate() throws {

        let farAway = try #require(TimeZone(identifier: "Pacific/Kiritimati"))
        let event = CountdownEvent.mock(
            title: "Trip",
            year: 2030,
            month: 1,
            day: 2,
            timeZone: farAway,
            timeSemantics: .floatingAllDay
        )

        let draft = EventDraft.mock(of: event)
        let spec = try #require(draft.targetDateSpecification)

        #expect(spec.year == 2030)
        #expect(spec.month == 1)
        #expect(spec.day == 2)
    }

    @Test
    func localTimeRangeEndKeepsWallClockAcrossDST() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let event = CountdownEvent.mock(
            title: "Weekend",
            year: 2026,
            month: 3,
            day: 28,
            hour: 9,
            minute: 0,
            timeZone: utc,
            timeSemantics: .floatingLocalTime
        )
        event.endYear = 2026
        event.endMonth = 3
        event.endDay = 30
        event.endHour = 9
        event.endMinute = 0

        event.rangeDurationSeconds = 47 * 3_600
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 1)))

        let occurrence = try #require(
            EventOccurrenceResolver().nextOccurrence(for: event, now: now, userTimeZone: utc)
        )
        let end = try #require(occurrence.endDate)
        let parts = calendar.dateComponents([.day, .hour, .minute], from: end)

        #expect(parts.day == 30)
        #expect(parts.hour == 9)
        #expect(parts.minute == 0)
    }
}
