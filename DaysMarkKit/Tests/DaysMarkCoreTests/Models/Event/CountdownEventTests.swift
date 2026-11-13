//
//  CountdownEventTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct CountdownEventTests {

    @Test
    func insertThenFetchesTheStoredEvent() throws {
        // Given
        let context = try makeContext()
        context.insert(
            CountdownEvent.mock(title: "New Year", year: 2027, month: 1, day: 1)
        )

        // When
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())

        // Then
        #expect(events.count == 1)
        #expect(events.first?.title == "New Year")
        #expect(events.first?.targetYear == 2027)
        #expect(events.first?.repeatRule == .never)
    }

    @Test
    func targetComponentsThenReflectTheStoredFields() throws {
        // Given
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let event = CountdownEvent.mock(
            title: "搬家",
            year: 2026,
            month: 8,
            day: 20,
            hour: 9,
            minute: 30,
            timeZone: berlin
        )

        // When
        let components = event.targetComponents

        // Then
        #expect(components.year == 2026)
        #expect(components.month == 8)
        #expect(components.day == 20)
        #expect(components.hour == 9)
        #expect(components.minute == 30)
        #expect(components.timeZone == berlin)
    }

    @Test
    func targetComponentsWhenAllDayThenHaveNoTime() {
        // Given / When
        let event = CountdownEvent.mock(title: "考试", year: 2026, month: 6, day: 1)

        // Then
        #expect(event.targetComponents.hour == nil)
        #expect(event.targetComponents.minute == nil)
    }

    @Test
    func timeZoneThenIsTheStoredIdentifier() throws {
        // Given / When
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let event = CountdownEvent.mock(title: "旅行", year: 2026, month: 5, day: 3, timeZone: tokyo)

        // Then
        #expect(event.timeZone == tokyo)
    }

    @Test
    func timeZoneWhenTheIdentifierIsUnknownThenIsNil() {
        // Given
        let event = CountdownEvent.mock(title: "x", year: 2026, month: 1, day: 1)

        // When
        event.timeZoneIdentifier = "Not/AZone"

        // Then
        #expect(event.timeZone == nil)
    }

    @Test
    func endComponentsWithoutAnEndThenAreNil() {
        // Given / When
        let event = CountdownEvent.mock(title: "生日", year: 2026, month: 3, day: 9)

        // Then
        #expect(event.endComponents == nil)
    }

    @Test
    func endComponentsThenUseTheEventTimeZone() throws {
        // Given
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let event = CountdownEvent.mock(
            title: "假期",
            year: 2026,
            month: 7,
            day: 1,
            timeZone: berlin,
            endYear: 2026,
            endMonth: 7,
            endDay: 14
        )

        // When
        let end = try #require(event.endComponents)

        // Then
        #expect(end.year == 2026)
        #expect(end.month == 7)
        #expect(end.day == 14)
        #expect(end.timeZone == berlin)
    }

    @Test
    func categoryWhenItsRecordIsDeletedThenIsNilAndTheEventStays() throws {
        let context = try makeContext()
        let category = EventCategory(builtIn: .important)
        let event = CountdownEvent.mock(
            title: "搬家",
            year: 2026,
            month: 8,
            day: 20,
            category: category
        )
        context.insert(category)
        context.insert(event)
        try context.save()

        context.delete(category)
        try context.save()

        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
        #expect(events.count == 1)
        #expect(events.first?.category == nil)
        #expect(try context.fetch(FetchDescriptor<EventCategory>()).isEmpty)
    }

    @Test
    func categoryThenListsItsEvents() throws {
        // Given / When
        let context = try makeContext()
        let category = EventCategory(name: "工作")
        context.insert(category)
        context.insert(
            CountdownEvent.mock(title: "上线", year: 2026, month: 9, day: 1, category: category)
        )
        try context.save()

        // Then
        #expect(category.events?.count == 1)
        #expect(category.events?.first?.title == "上线")
    }

    private func makeContext() throws -> ModelContext {
        ModelContext(.mockInMemory())
    }
}
