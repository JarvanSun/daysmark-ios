//
//  EventLookupErrorExtensionsTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Testing

@testable import DaysMark

struct EventLookupErrorExtensionsTests {
    @Test func intentErrorWhenTheEventIsNotFoundThenIsTheSystemsEntityNotFound() {
        // Given
        let expected: Error = AppIntentError.Unrecoverable.entityNotFound

        // When
        let error = EventLookupError.eventNotFound.intentError

        // Then
        #expect(String(reflecting: error) == String(reflecting: expected))
    }

    @Test func intentErrorWhenTheReminderIsNotAllowedThenIsTheSystemsNotAllowed() {
        // Given
        let expected: Error = AppIntentError.Unrecoverable.notAllowed

        // When
        let error = EventLookupError.reminderNotAllowed.intentError

        // Then
        #expect(String(reflecting: error) == String(reflecting: expected))
    }

    @Test func intentErrorThenTellsTheTwoSystemErrorsApart() {
        // Given / When
        let notFound = EventLookupError.eventNotFound.intentError
        let notAllowed = EventLookupError.reminderNotAllowed.intentError

        // Then
        #expect(String(reflecting: notFound) != String(reflecting: notAllowed))
    }

    @Test func intentErrorWhenTheDraftIsInvalidThenAsksToCheckTheDate() {
        // Given / When
        let error = EventLookupError.invalidDraft.intentError

        // Then
        #expect(error as? ImportantDateIntentError == .invalidDate)
    }
}
