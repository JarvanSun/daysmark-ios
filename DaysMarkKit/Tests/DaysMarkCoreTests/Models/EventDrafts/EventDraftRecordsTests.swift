//
//  EventDraftRecordsTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct EventDraftRecordsTests {
    @Test
    func initFromEventThenCopiesItsContentInTheUserTimeZone() throws {
        // Given
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let event = CountdownEvent.mock(
            title: "Birthday",
            year: 2026,
            month: 3,
            day: 9,
            timeZone: berlin,
            repeatRule: .yearly
        )

        // When
        let draft = EventDraft(event, at: .mockNow, in: berlin)

        // Then
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = berlin
        let components = calendar.dateComponents([.year, .month, .day], from: draft.targetDate)
        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 9)
        #expect(draft.title == "Birthday")
        #expect(draft.repeatRule == .yearly)
        #expect(draft.timeZone == berlin)
    }

    @Test
    func initFromEventThenOrdersRemindersByDaysBefore() throws {
        // Given
        let event = CountdownEvent.mock(reminderDays: [7, 0])

        // When
        let draft = EventDraft.mock(of: event)

        // Then
        #expect(draft.reminders.map(\.daysBefore) == [0, 7])
        #expect(Set(draft.reminders.map(\.id)) == Set((event.reminders ?? []).map(\.id)))
    }

    @Test
    func initFromEventWhenSavedBackThenKeepsTheStoredDay() throws {
        // Given
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let container = ModelContainer.mockInMemory()
        let event = CountdownEvent.mock(
            title: "Birthday",
            year: 2026,
            month: 3,
            day: 9,
            timeZone: berlin
        )
        container.mainContext.insert(event)
        try container.mainContext.save()

        // When
        let draft = EventDraft(event, at: .mockNow, in: berlin)
        try SwiftDataEventRepository.mock(in: container).save(draft, replacing: event.id)

        // Then
        #expect(event.targetYear == 2026)
        #expect(event.targetMonth == 3)
        #expect(event.targetDay == 9)
    }

    @Test
    func initFromRevisionThenRestoresTheSnapshotWithItsRemindersAndNodes() throws {
        // Given
        let event = CountdownEvent.mock(title: "Trip", reminderDays: [3])
        let node = SpecialReminderNode(eventID: event.id, kind: .beforeDays, value: 100)
        node.event = event
        event.specialReminderNodes = [node]
        let revision = EventRevision(
            eventID: event.id,
            parentRevisionID: nil,
            conflictGroupID: .mockFocusRootGroupID,
            createdAt: .mockNow,
            event: event
        )

        // When
        let draft = EventDraft(revision, at: .mockNow, in: .mockUTC)

        // Then
        #expect(draft.title == "Trip")
        #expect(draft.targetDateSpecification?.year == 2030)
        #expect(draft.targetDateSpecification?.month == 9)
        #expect(draft.targetDateSpecification?.day == 10)
        #expect(draft.reminders.map(\.daysBefore) == [3])
        #expect(draft.reminders.map(\.id) == (event.reminders ?? []).map(\.id))
        #expect(
            draft.specialReminderNodes == [
                SpecialReminderNodeDraft(id: node.id, kind: .beforeDays, value: 100)
            ]
        )
        #expect(draft.baseRevisionID == nil)
    }
}
