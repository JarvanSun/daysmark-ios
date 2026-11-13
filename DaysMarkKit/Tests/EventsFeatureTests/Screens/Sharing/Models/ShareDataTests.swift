//
//  ShareDataTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import Foundation
import Testing

@testable import DaysMarkCore
@testable import EventsFeature

struct ShareDataTests {
    @Test(arguments: ["en_US", "de_DE", "zh_Hans_CN"])
    func contentThenWritesTheYearAndTheSharedPhrase(locale: String) throws {
        // Given
        let event = makeEvent("Birthday", icon: "birthday.cake")

        // When
        let card = try makeContent(event, locale: locale)

        // Then
        #expect(card.absoluteTime.contains("2026"))
        #expect(card.referenceDateText.contains("2026"))
        #expect(
            card.relativeTime
                == RelativeTimePhrase(.init(days: 18, direction: .upcoming)).text
        )
        #expect(card.appearance == EventAppearance(storedKey: "birthday.cake"))
        #expect(card.calendarName == nil)
    }

    @Test func contentThenAddsTheCategoryOnlyOnRequestAndNeverPrivateFields() throws {
        // Given
        let event = makeEvent("Trip", icon: "airplane")
        event.sourceKind = .contacts

        // When
        let closed = try makeContent(event)
        let open = try makeContent(event, includesCategory: true)

        // Then
        #expect(closed.category == nil)
        #expect(!closed.plainText.contains("Private category"))
        #expect(open.category == "Private category")
        #expect(open.plainText.contains("Private category"))
        #expect(closed != open)

        for forbidden in [
            event.id.uuidString, event.recordID.uuidString, "D96772", "Contacts", "GMT",
        ] {
            #expect(!open.plainText.contains(forbidden))
        }
    }

    @Test func contentForATimedEventThenKeepsTheLocalTimeWithoutNamingATimeZone() throws {
        // Given
        let event = CountdownEvent.mock(
            title: "Train",
            year: 2026,
            month: 9,
            day: 23,
            hour: 18,
            minute: 45,
            timeZone: .gmt,
            timeSemantics: .floatingLocalTime
        )

        // When
        let card = try makeContent(event, locale: "de_DE")

        // Then
        #expect(card.absoluteTime.contains("18:45"))
        #expect(!card.plainText.contains("Time zone"))
        #expect(!card.plainText.contains("wherever"))
    }

    @Test func contentForARangeThenWritesTheYearOfBothEnds() throws {
        // Given
        let event = CountdownEvent.mock(
            title: "Holiday",
            year: 2026,
            month: 12,
            day: 28,
            timeZone: .gmt,
            endYear: 2027,
            endMonth: 1,
            endDay: 3
        )

        // When
        let card = try makeContent(event)

        // Then
        #expect(card.absoluteTime.contains("2026"))
        #expect(card.absoluteTime.contains("2027"))
        #expect(!card.relativeTime.isEmpty)
    }

    @Test func contentForAFixedMomentThenKeepsItsLocalDateInAnotherTimeZone() throws {
        // Given
        let eventZone = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let viewingZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
        let event = CountdownEvent.mock(
            title: "Flight",
            year: 2026,
            month: 9,
            day: 23,
            hour: 0,
            minute: 30,
            timeZone: eventZone,
            timeSemantics: .fixedInstant
        )

        // When
        let card = try makeContent(event, timeZone: viewingZone, locale: "de_DE")

        // Then
        #expect(card.absoluteTime.contains("23."))
        #expect(card.absoluteTime.contains("00:30"))
        #expect(!card.plainText.contains("Tokyo"))
        #expect(!card.plainText.contains("Los_Angeles"))
    }

    @Test func contentForAChineseLeapMonthThenKeepsTheLeapMonthAndNamesTheCalendar() throws {
        // Given
        let anchor = Date.mock(2023, 3, 22, hour: 12)
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = .gmt
        let parts = chinese.dateComponents([.era, .year, .month, .day], from: anchor)
        let lunar = {
            let event = CountdownEvent.mock(
                title: "Lunar",
                year: parts.year!,
                month: parts.month!,
                day: parts.day!,
                timeZone: .gmt,
                calendarSystem: .chinese
            )
            event.targetEra = parts.era

            return event
        }
        let leap = lunar()
        leap.targetIsLeapMonth = true

        // When
        let leapCard = try makeContent(leap, now: anchor, locale: "zh_Hans_CN")
        let ordinaryCard = try makeContent(lunar(), now: anchor, locale: "zh_Hans_CN")

        // Then
        #expect(leapCard.calendarName == String(localized: EventCalendarSystem.chinese.title))
        #expect(leapCard.absoluteTime.contains("闰"))
        #expect(ordinaryCard.absoluteTime != leapCard.absoluteTime)
    }

    @Test func contentForAnUmmAlQuraDateThenKeepsItsYearAndNamesTheCalendar() throws {
        // Given
        let event = CountdownEvent.mock(
            title: "Date",
            year: 1448,
            month: 3,
            day: 20,
            timeZone: .gmt,
            calendarSystem: .islamicUmmAlQura
        )

        // When
        let card = try makeContent(event)

        // Then
        #expect(card.absoluteTime.contains("1448"))
        #expect(card.calendarName == String(localized: EventCalendarSystem.islamicUmmAlQura.title))
    }

    @Test func contentForADeletedOrMissingEventThenIsMissing() {
        // Given
        let deleted = makeEvent("Deleted")
        deleted.deletedAt = .mockNow

        // Then
        #expect(content(of: [deleted]) == nil)
        #expect(content(of: []) == nil)
    }

    @Test func contentThenLeavesOutTheCategoryAndTheSourceByDefault() throws {
        // Given
        let event = makeEvent("Trip")
        event.sourceKind = .contacts

        // When
        let card = try #require(content(of: [event]))

        // Then
        #expect(card.category == nil)
        #expect(!card.plainText.contains("Contacts"))
        #expect(!card.absoluteTime.isEmpty)
        #expect(!card.referenceDateText.isEmpty)
        #expect(card.appearance == EventAppearance(storedKey: event.icon))
    }
}

private extension ShareDataTests {
    var category: EventCategory { EventCategory(name: "Private category") }

    func makeEvent(_ title: String, icon: String = "") -> CountdownEvent {
        CountdownEvent.mock(title: title, year: 2026, month: 9, day: 23, timeZone: .gmt, icon: icon)
    }

    func content(of events: [CountdownEvent]) -> EventShareContent? {
        ShareData(events: events).content(
            of: events.first?.id ?? .mockMissing,
            includesCategory: false,
            at: .mock(now: .mock(2026, 9, 5, hour: 12))
        )
    }

    func makeContent(
        _ event: CountdownEvent,
        includesCategory: Bool = false,
        now: Date = .mock(2026, 9, 5, hour: 12),
        timeZone: TimeZone = .gmt,
        locale: String = "en_US"
    ) throws -> EventShareContent {
        let category = category
        event.categoryID = category.id

        return try #require(
            ShareData(events: [event], categories: [category]).content(
                of: event.id,
                includesCategory: includesCategory,
                at: .mock(now: now, timeZone: timeZone, locale: Locale(identifier: locale))
            )
        )
    }
}
