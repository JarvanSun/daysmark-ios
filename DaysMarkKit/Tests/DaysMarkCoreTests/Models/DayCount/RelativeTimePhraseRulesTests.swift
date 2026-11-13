//
//  RelativeTimePhraseRulesTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct RelativeTimePhraseRulesTests {
    @Test
    func phraseWhenAllDayThenIsTheDayPhrase() {
        // Given
        let subject = makeSubject(dayCount: DayCount(days: 12, direction: .upcoming))

        // When
        let phrase = makeRules().phrase(for: subject)

        // Then
        #expect(phrase == RelativeTimePhrase(DayCount(days: 12, direction: .upcoming)))
        #expect(phrase.targetDate == nil)
        #expect(phrase.phase == .point)
    }

    @Test(arguments: [(90, "2"), (30, "30"), (-45, "45")])
    func phraseWhenTimedOnItsDayThenCountsHoursOrMinutes(minutesAway: Int, number: String) {
        // Given
        let target = Date.mock(2030, 9, 10).addingTimeInterval(TimeInterval(minutesAway * 60))
        let subject = makeSubject(timeSemantics: .floatingLocalTime, date: target)

        // When
        let phrase = makeRules().phrase(for: subject)

        // Then
        #expect(phrase.number == number)
        #expect(phrase.targetDate == target)
    }

    @Test
    func phraseWhenTimedOnAnotherDayThenIsTheDayPhrase() {
        // Given
        let subject = makeSubject(
            dayCount: DayCount(days: 3, direction: .upcoming),
            timeSemantics: .floatingLocalTime,
            date: .mock(2030, 9, 13)
        )

        // When
        let phrase = makeRules().phrase(for: subject)

        // Then
        #expect(phrase == RelativeTimePhrase(DayCount(days: 3, direction: .upcoming)))
    }

    @Test
    func phraseWhenAFixedInstantThenJudgesTheDayInTheEventTimeZone() {
        // Given
        let target = Date.mock(2030, 9, 10, hour: 16)
        let subject = makeSubject(
            dayCount: DayCount(days: 1, direction: .upcoming),
            timeSemantics: .fixedInstant,
            timeZone: .mockTokyo,
            date: target
        )

        // When
        let phrase = makeRules().phrase(for: subject)

        // Then
        #expect(phrase.targetDate == nil)
    }

    @Test(arguments: [
        (9, RelativeTimePhrase.Phase.beforeStart),
        (10, .ongoing),
        (12, .ongoing),
        (13, .ended),
    ])
    func phraseWhenAnAllDayRangeThenNamesWhereTodayFallsInIt(
        today: Int,
        expected: RelativeTimePhrase.Phase
    ) {
        // Given
        let subject = makeSubject(
            rangeStart: .mock(2030, 9, 10, hour: 0),
            rangeEnd: .mock(2030, 9, 12, hour: 0)
        )

        // When
        let phrase = makeRules(now: .mock(2030, 9, today, hour: 18)).phrase(for: subject)

        // Then
        #expect(phrase.phase == expected)
    }

    @Test(arguments: [
        (11, RelativeTimePhrase.Phase.beforeStart),
        (12, .ongoing),
        (15, .ended),
    ])
    func phraseWhenATimedRangeThenNamesWhereTheMomentFallsInIt(
        hour: Int,
        expected: RelativeTimePhrase.Phase
    ) {
        // Given
        let subject = makeSubject(
            timeSemantics: .floatingLocalTime,
            date: .mock(2030, 9, 10, hour: 12),
            rangeStart: .mock(2030, 9, 10, hour: 12),
            rangeEnd: .mock(2030, 9, 10, hour: 14)
        )

        // When
        let phrase = makeRules(now: .mock(2030, 9, 10, hour: hour)).phrase(for: subject)

        // Then
        #expect(phrase.phase == expected)
    }

    private func makeRules(now: Date = .mock(2030, 9, 10)) -> RelativeTimePhraseRules {
        RelativeTimePhraseRules(
            now: now,
            userTimeZone: .mockUTC,
            locale: Locale(identifier: "en_US")
        )
    }

    private func makeSubject(
        dayCount: DayCount = DayCount(days: 0, direction: .today),
        timeSemantics: EventTimeSemantics = .floatingAllDay,
        timeZone: TimeZone? = nil,
        date: Date? = nil,
        rangeStart: Date? = nil,
        rangeEnd: Date? = nil
    ) -> RelativeTimeSubject {
        RelativeTimeSubject(
            dayCount: dayCount,
            timeSemantics: timeSemantics,
            calendarSystem: .gregorian,
            timeZone: timeZone,
            date: date,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd
        )
    }
}
