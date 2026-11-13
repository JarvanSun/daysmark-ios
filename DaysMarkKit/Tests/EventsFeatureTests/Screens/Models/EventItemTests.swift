//
//  EventItemTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import Foundation
import Testing

@testable import DaysMarkCore
@testable import EventsFeature

struct EventItemTests {
    @Test(arguments: [(15, DayCount.Direction.upcoming), (1, .past)])
    func phraseThenIsTheWholeSharedPhraseAroundItsNumber(day: Int, direction: DayCount.Direction)
        throws
    {
        // Given
        let summary = EventItem.mock(.mock(day: day))

        // When
        let parts = try #require(presentation(of: summary).parts)

        // Then
        #expect(summary.direction == direction)
        #expect(parts.number == summary.counted.dayCount.days.formatted())
        #expect(
            withoutWhitespace(parts.leading + parts.number + parts.trailing)
                == withoutWhitespace(summary.phrase)
        )
        #expect(summary.phrase != parts.number + parts.trailing)
    }

    @Test(arguments: [10, 11, 9])
    func phraseForANamedDayThenHasNoNumberToEmphasize(day: Int) {
        // Given
        let summary = EventItem.mock(.mock(day: day))

        // Then
        #expect(presentation(of: summary).parts == nil)
        #expect(summary.phrase == RelativeTimePhrase(summary.counted.dayCount).text)
    }

    @Test func phraseForTodayThenIsTheNamedDayInTheUpcomingTint() {
        // Given
        let summary = EventItem.mock(.mock("Today", day: 10))

        // Then
        #expect(summary.direction == .today)
        #expect(summary.phrase == RelativeTimePhrase(.init(days: 0, direction: .today)).text)
        #expect(summary.tint == DayCount.Direction.today.tint)
        #expect(!summary.countsDown)
    }

    @Test func phraseForATimedEventThenCountsMinutesAndTheDateShowsTheTime() throws {
        // Given
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let target = Date.mock(2030, 9, 10, hour: 21, in: berlin)
        let event = CountdownEvent.mock(
            title: "Concert",
            year: 2030,
            month: 9,
            day: 10,
            hour: 21,
            minute: 0,
            timeZone: berlin,
            timeSemantics: .fixedInstant
        )
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.unitsStyle = .full
        let summary = { (now: Date) in
            EventItem.mock(event, at: .mock(now: now, timeZone: berlin))
        }

        // When
        let before = summary(target.addingTimeInterval(-30 * 60))
        let atTarget = summary(target)
        let after = summary(target.addingTimeInterval(30 * 60))

        // Then
        #expect(before.phrase == formatter.localizedString(from: .init(minute: 30)))
        #expect(presentation(of: before).number == "30")
        #expect(presentation(of: before).targetDate == target)
        #expect(before.date.contains("9:00"))
        #expect(atTarget.phrase != before.phrase)
        #expect(presentation(of: atTarget).number == nil)
        #expect(after.phrase == formatter.localizedString(from: .init(minute: -30)))
    }

    @Test func phraseForARangeThenSaysWhetherItStartsEndsOrEnded() {
        // Given
        let event = CountdownEvent.mock(
            title: "Trip",
            year: 2030,
            month: 9,
            day: 10,
            timeZone: .gmt,
            endYear: 2030,
            endMonth: 9,
            endDay: 12,
            timeSemantics: .floatingAllDay
        )
        let summary = { (day: Int) in
            EventItem.mock(event, at: .mock(now: .mock(2030, 9, day)))
        }

        // When
        let phases = [1, 11, 13].map { presentation(of: summary($0)).phase }
        let phrases = [1, 11, 13].map { summary($0).phrase }

        // Then
        #expect(phases == [.beforeStart, .ongoing, .ended])
        #expect(Set(phrases).count == 3)
        #expect(
            phrases.allSatisfy { phrase in
                phrase != RelativeTimePhrase(summary(1).counted.dayCount).text
            }
        )
    }

    @Test func dateForANonGregorianEventThenIsWrittenInItsCalendar() throws {
        // Given
        let riyadh = try #require(TimeZone(identifier: "Asia/Riyadh"))
        let anchor = Date.mock(2026, 2, 18, hour: 12, in: riyadh)
        var islamic = Calendar(identifier: .islamicUmmAlQura)
        islamic.timeZone = riyadh
        let parts = islamic.dateComponents([.era, .year, .month, .day], from: anchor)
        let event = CountdownEvent.mock(
            title: "Ramadan",
            year: try #require(parts.year),
            month: try #require(parts.month),
            day: try #require(parts.day),
            timeZone: riyadh,
            calendarSystem: .islamicUmmAlQura
        )
        event.targetEra = parts.era
        let time = CurrentTime.mock(now: .mock(2026, 1, 1, in: riyadh), timeZone: riyadh)
        let expected = DateFormatter()
        expected.locale = time.locale
        expected.calendar = islamic
        expected.timeZone = riyadh
        expected.setLocalizedDateFormatFromTemplate("MMM d")

        // When
        let summary = EventItem.mock(event, at: time)

        // Then
        #expect(summary.date == expected.string(from: anchor))
    }

    @Test func dateThenAddsTheYearOnlyWhenItIsNotThisYear() {
        // Given
        let thisYear = EventItem.mock(.mock(day: 15))
        let nextYear = EventItem.mock(.mock(year: 2031))

        // Then
        #expect(thisYear.date == "Sep 15")
        #expect(thisYear.dateWithWeekday == "Sun, Sep 15")
        #expect(nextYear.date == "Sep 15, 2031")
    }

    @Test(arguments: [DayCount.Direction.past, .today, .upcoming])
    func tintThenIsTheSharedDirectionTint(direction: DayCount.Direction) {
        // Given
        let day = [DayCount.Direction.past: 8, .today: 10, .upcoming: 12][direction] ?? 10
        let summary = EventItem.mock(.mock(day: day))

        // Then
        #expect(summary.direction == direction)
        #expect(summary.tint == direction.tint)
    }

    @Test func directionTintsThenSeparatePastFromUpcoming() {
        #expect(DayCount.Direction.past.tint == DaysMarkColor.past)
        #expect(DayCount.Direction.upcoming.tint == DaysMarkColor.upcoming)
        #expect(DayCount.Direction.today.tint == DaysMarkColor.upcoming)
    }

    @Test func accessibilityLabelThenReadsTheTitleThePhraseAndTheDate() {
        // Given
        let summary = EventItem.mock(.mock("Trip", day: 22))

        // Then
        #expect(
            summary.accessibilityLabel
                == ["Trip", summary.phrase, summary.dateWithWeekday].joined(separator: ", ")
        )
        #expect(summary.accessibilityLabel.contains("12"))
    }

    @Test func accessibilityCopyForDayCountsThenReflectsTheDirection() {
        // Given
        let upcoming = DayCount(days: 3, direction: .upcoming).accessibilityLabel(title: "T")
        let past = DayCount(days: 3, direction: .past).accessibilityLabel(title: "T")

        // Then
        #expect(upcoming != past)
        #expect(upcoming.contains("3"))
        #expect(past.contains("3"))
    }
}

private extension EventItemTests {
    func presentation(of summary: EventItem) -> RelativeTimePhrase {
        summary.counted.relativeTimePhrase(
            at: summary.now,
            userTimeZone: summary.timeZone,
            locale: summary.locale
        )
    }

    func withoutWhitespace(_ text: String) -> String {
        text.components(separatedBy: .whitespacesAndNewlines).joined()
    }
}
