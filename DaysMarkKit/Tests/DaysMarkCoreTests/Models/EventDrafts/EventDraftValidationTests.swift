//
//  EventDraftValidationTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct EventDraftValidationTests {
    @Test
    func isValidWhenTheDraftIsCompleteThenIsTrue() {
        #expect(EventDraft.mock("Trip").isValid)
    }

    @Test
    func isValidWhenTheTitleIsBlankThenIsFalse() {
        #expect(!EventDraft.mock("   ").isValid)
    }

    @Test
    func isValidWhenTheEndIsBeforeTheStartThenIsFalse() {
        // Given
        var draft = EventDraft.mock("Trip", on: .mock(2030, 1, 10))

        // When
        draft.endDate = .mock(2030, 1, 9)

        // Then
        #expect(!draft.isValid)
    }

    @Test
    func isValidWhenTheEndIsOnOrAfterTheStartThenIsTrue() {
        // Given
        var draft = EventDraft.mock("Trip", on: .mock(2030, 1, 10))

        // When
        draft.endDate = .mock(2030, 1, 12)

        // Then
        #expect(draft.isValid)
    }

    @Test(arguments: [
        (
            EventTimeSemantics.floatingAllDay,
            ReminderDraft(kind: .exactTimeOffset, minutesBefore: 5)
        ),
        (.floatingAllDay, ReminderDraft(daysBefore: -1)),
        (.floatingAllDay, ReminderDraft(hour: 24)),
        (.floatingLocalTime, ReminderDraft(kind: .allDayOffsetAtTime)),
        (.floatingLocalTime, ReminderDraft(kind: .exactTimeOffset, minutesBefore: nil)),
    ])
    func isValidWhenAReminderDoesNotFitTheTimeSemanticsThenIsFalse(
        semantics: EventTimeSemantics,
        reminder: ReminderDraft
    ) {
        // Given
        var draft = EventDraft.mock("Trip")
        draft.timeSemantics = semantics

        // When
        draft.reminders = [reminder]

        // Then
        #expect(!draft.isValid)
    }

    @Test
    func isValidWhenSpecialNodesHaveNoNotificationTimeThenIsFalse() {
        // Given
        var draft = EventDraft.mock("Trip")
        draft.specialReminderNodes = [SpecialReminderNodeDraft(kind: .beforeDays, value: 100)]

        // When / Then
        #expect(!draft.isValid)

        draft.specialNodeNotificationMinuteOfDay = 540
        #expect(draft.isValid)
    }
}
