//
//  EventDraftTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct EventDraftTests {
    @Test
    func initThenStartsFromTheGivenDayCategoryAndTimeZone() {
        // Given
        let categoryID = UUID()

        // When
        let draft = EventDraft(startingOn: .mockNow, categoryID: categoryID, timeZone: .mockUTC)

        // Then
        #expect(draft.targetDate == .mockNow)
        #expect(draft.categoryID == categoryID)
        #expect(draft.timeZone == .mockUTC)
        #expect(draft.title.isEmpty)
        #expect(draft.endDate == nil)
        #expect(draft.timeSemantics == .floatingAllDay)
        #expect(draft.repeatRule == .never)
        #expect(draft.reminders.isEmpty)
        #expect(draft.baseRevisionID == nil)
    }

    @Test
    func timeSemanticsChangedWhenTimedThenTurnsRemindersIntoExactOffsets() {
        // Given
        var draft = EventDraft.mock
        draft.reminders = [ReminderDraft(daysBefore: 3, hour: 9, minute: 30)]
        draft.timeSemantics = .floatingLocalTime

        // When
        draft.timeSemanticsChanged()

        // Then
        #expect(draft.reminders.map(\.kind) == [.exactTimeOffset])
        #expect(draft.reminders.map(\.minutesBefore) == [0])
    }

    @Test
    func timeSemanticsChangedWhenAllDayThenTurnsRemindersIntoDayOffsets() {
        // Given
        var draft = EventDraft.mock
        draft.reminders = [ReminderDraft(kind: .exactTimeOffset, minutesBefore: 15)]
        draft.timeSemantics = .floatingAllDay

        // When
        draft.timeSemanticsChanged()

        // Then
        #expect(draft.reminders.map(\.kind) == [.allDayOffsetAtTime])
        #expect(draft.reminders.map(\.minutesBefore) == [nil])
    }

    @Test
    func removeRemindersThenDropsTheRemindersAtTheOffsets() {
        // Given
        var draft = EventDraft.mock
        draft.reminders = [0, 1, 7].map { ReminderDraft(daysBefore: $0) }

        // When
        draft.removeReminders(atOffsets: [0, 2])

        // Then
        #expect(draft.reminders.map(\.daysBefore) == [1])
    }
}
