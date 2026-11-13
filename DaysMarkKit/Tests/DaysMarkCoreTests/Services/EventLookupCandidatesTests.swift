//
//  EventLookupCandidatesTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct EventLookupCandidatesTests {
    @Test
    func candidateCreatingThenIsAnAllDayImportantDateWithItsConfirmation() throws {
        // Given / When
        let candidate = try EventLookup.mock(in: .mockInMemory()).candidate(creating: .mockTrip)

        // Then
        #expect(candidate.eventID == nil)
        #expect(candidate.draft.title == "Trip")
        #expect(candidate.draft.targetDate == .mock(2030, 9, 10))
        #expect(candidate.draft.endDate == nil)
        #expect(candidate.draft.timeSemantics == .floatingAllDay)
        #expect(candidate.draft.repeatRule == .never)
        #expect(candidate.draft.categoryID == BuiltInCategory.important.id)
        #expect(candidate.draft.timeZone == .mockUTC)
        #expect(candidate.draft.reminders.isEmpty)
        #expect(
            candidate.confirmation == "Confirm Trip, September 10, 2030, category Important Date."
        )
    }

    @Test
    func candidateCreatingWhenEveryFieldIsGivenThenCarriesThemAndNamesTheCategory() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let family = EventCategory(name: "Family")
        container.mainContext.insert(family)
        try container.mainContext.save()
        var input = EventCreationInput(title: "  Reunion ", startDate: .mock(2030, 9, 10))
        input.endDate = .mock(2030, 9, 12)
        input.categoryID = family.id
        input.repeatRule = .yearly

        // When
        let candidate = try EventLookup.mock(in: container).candidate(creating: input)

        // Then
        #expect(candidate.draft.endDate == .mock(2030, 9, 12))
        #expect(candidate.draft.categoryID == family.id)
        #expect(candidate.draft.repeatRule == .yearly)
        #expect(candidate.confirmation == "Confirm Reunion, September 10, 2030, category Family.")
    }

    @Test
    func candidateCreatingWhenItIncludesATimeThenIsTimedAndConfirmsTheTime() throws {
        // Given
        var input = EventCreationInput.mockTrip
        input.includesTime = true

        // When
        let candidate = try EventLookup.mock(in: .mockInMemory()).candidate(creating: input)

        // Then
        #expect(candidate.draft.timeSemantics == .floatingLocalTime)
        #expect(candidate.confirmation.hasPrefix("Confirm Trip, September 10, 2030 at 12:00"))
        #expect(candidate.confirmation.hasSuffix("PM, category Important Date."))
    }

    @Test
    func candidateCreatingWhenAnAllDayReminderIsAskedThenRemindsAtNineThatManyDaysBefore() throws {
        // Given
        var input = EventCreationInput.mockTrip
        input.reminderDaysBefore = 3

        // When
        let candidate = try EventLookup.mock(in: .mockInMemory()).candidate(creating: input)

        // Then
        let reminder = try #require(candidate.draft.reminders.first)
        #expect(candidate.draft.reminders.count == 1)
        #expect(reminder.kind == .allDayOffsetAtTime)
        #expect(reminder.daysBefore == 3)
        #expect(reminder.hour == 9)
        #expect(reminder.minute == 0)
        #expect(reminder.minutesBefore == nil)
    }

    @Test
    func candidateCreatingWhenATimedReminderIsAskedThenRemindsThatManyDaysOfMinutesBefore() throws {
        // Given
        var input = EventCreationInput.mockTrip
        input.includesTime = true
        input.reminderDaysBefore = 2

        // When
        let candidate = try EventLookup.mock(in: .mockInMemory()).candidate(creating: input)

        // Then
        let reminder = try #require(candidate.draft.reminders.first)
        #expect(candidate.draft.reminders.count == 1)
        #expect(reminder.kind == .exactTimeOffset)
        #expect(reminder.minutesBefore == 2_880)
    }

    @Test
    func candidateCreatingWhenTheReminderIsNegativeThenIsNotAllowed() {
        // Given
        var input = EventCreationInput.mockTrip
        input.reminderDaysBefore = -1

        // When / Then
        #expect(throws: EventLookupError.reminderNotAllowed) {
            try EventLookup.mock(in: .mockInMemory()).candidate(creating: input)
        }
    }

    @Test
    func candidateCreatingWhenTheTitleIsBlankThenIsInvalid() {
        // Given
        let input = EventCreationInput(title: "  ", startDate: .mock(2030, 9, 10))

        // When / Then
        #expect(throws: EventLookupError.invalidDraft) {
            try EventLookup.mock(in: .mockInMemory()).candidate(creating: input)
        }
    }

    @Test
    func candidateCreatingWhenTheEndIsBeforeTheStartThenIsInvalid() {
        // Given
        var input = EventCreationInput.mockTrip
        input.endDate = .mock(2030, 9, 1)

        // When / Then
        #expect(throws: EventLookupError.invalidDraft) {
            try EventLookup.mock(in: .mockInMemory()).candidate(creating: input)
        }
    }

    @Test
    func candidateEditingWhenOnlyTheTitleChangesThenKeepsEverythingElse() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let event = try makeStoredEvent(in: container)
        let original = EventDraft.mock(of: event)

        // When
        let candidate = try EventLookup.mock(in: container).candidate(
            editing: event.id,
            with: EventEditInput(
                title: "Journey",
                startDate: nil,
                includesTime: nil,
                categoryID: nil
            )
        )

        // Then
        var expected = original
        expected.title = "Journey"
        #expect(candidate.eventID == event.id)
        #expect(candidate.draft == expected)
        #expect(
            candidate.confirmation
                == "Confirm Journey, September 10, 2030, category Important Date."
        )
    }

    @Test
    func candidateEditingWhenTheStartDateChangesThenClearsTheEndDate() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        var draft = EventDraft.mock("Trip", on: .mock(2030, 9, 10))
        draft.endDate = .mock(2030, 9, 12)
        let eventID = try SwiftDataEventRepository.mock(in: container).save(draft, replacing: nil)

        // When
        let candidate = try EventLookup.mock(in: container).candidate(
            editing: eventID,
            with: EventEditInput(
                title: nil,
                startDate: .mock(2030, 10, 1),
                includesTime: nil,
                categoryID: nil
            )
        )

        // Then
        #expect(candidate.draft.targetDate == .mock(2030, 10, 1))
        #expect(candidate.draft.endDate == nil)
    }

    @Test
    func candidateEditingWhenATimeIsAddedThenTurnsItsRemindersIntoExactOffsets() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        var draft = EventDraft.mock("Trip", on: .mock(2030, 9, 10))
        draft.reminders = [ReminderDraft(daysBefore: 1, hour: 9, minute: 0)]
        let eventID = try SwiftDataEventRepository.mock(in: container).save(draft, replacing: nil)

        // When
        let candidate = try EventLookup.mock(in: container).candidate(
            editing: eventID,
            with: EventEditInput(title: nil, startDate: nil, includesTime: true, categoryID: nil)
        )

        // Then
        #expect(candidate.draft.timeSemantics == .floatingLocalTime)
        #expect(candidate.draft.reminders.map(\.kind) == [.exactTimeOffset])
        #expect(candidate.draft.reminders.map(\.minutesBefore) == [0])
    }

    @Test
    func candidateEditingWhenTheCategoryChangesThenConfirmsTheNewCategory() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let family = EventCategory(name: "Family")
        container.mainContext.insert(family)
        let event = try makeStoredEvent(in: container)

        // When
        let candidate = try EventLookup.mock(in: container).candidate(
            editing: event.id,
            with: EventEditInput(
                title: nil,
                startDate: nil,
                includesTime: nil,
                categoryID: family.id
            )
        )

        // Then
        #expect(candidate.draft.categoryID == family.id)
        #expect(candidate.confirmation == "Confirm Trip, September 10, 2030, category Family.")
    }

    @Test
    func candidateEditingWhenTheEventIsUnknownThenIsNotFound() {
        // Given / When / Then
        #expect(throws: EventLookupError.eventNotFound) {
            try EventLookup.mock(in: .mockInMemory()).candidate(
                editing: UUID(),
                with: EventEditInput(
                    title: "Journey",
                    startDate: nil,
                    includesTime: nil,
                    categoryID: nil
                )
            )
        }
    }

    @Test
    func candidateEditingWhenTheEventIsInRecentlyDeletedThenIsNotFound() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let event = try makeStoredEvent(in: container)
        try SwiftDataEventRepository.mock(in: container).delete(eventID: event.id)

        // When / Then
        #expect(throws: EventLookupError.eventNotFound) {
            try EventLookup.mock(in: container).candidate(
                editing: event.id,
                with: EventEditInput(
                    title: "Journey",
                    startDate: nil,
                    includesTime: nil,
                    categoryID: nil
                )
            )
        }
    }

    @Test
    func candidateEditingWhenTheNewTitleIsBlankThenIsInvalid() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let event = try makeStoredEvent(in: container)

        // When / Then
        #expect(throws: EventLookupError.invalidDraft) {
            try EventLookup.mock(in: container).candidate(
                editing: event.id,
                with: EventEditInput(title: " ", startDate: nil, includesTime: nil, categoryID: nil)
            )
        }
    }

    @Test
    func candidateWhenSavedThenTheEventIsFoundWithItsNextOccurrence() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let lookup = EventLookup.mock(in: container)
        let candidate = try lookup.candidate(creating: .mockTrip)

        // When
        let eventID = try SwiftDataEventRepository.mock(in: container).save(
            candidate.draft,
            replacing: nil
        )

        // Then
        #expect(
            lookup.events(withIDs: [eventID]) == [
                EventMatch(
                    id: eventID,
                    title: "Trip",
                    date: .mock(2030, 9, 10, hour: 0),
                    categoryName: "Important Date"
                )
            ]
        )
    }

    private func makeStoredEvent(in container: ModelContainer) throws -> CountdownEvent {
        let service = SwiftDataEventRepository.mock(in: container)

        return try service.create(from: .mock("Trip", on: .mock(2030, 9, 10)))
    }
}
