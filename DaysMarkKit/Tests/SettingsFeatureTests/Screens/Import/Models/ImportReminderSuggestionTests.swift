//
//  ImportReminderSuggestionTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Testing

@testable import SettingsFeature

struct ImportReminderSuggestionTests {
    @Test func configurationWhenEnabledThenCarriesDaysAndTime() {
        // Given / When
        let suggestion = ImportReminderSuggestion(
            isEnabled: true,
            daysBefore: 3,
            time: .init(hour: 18, minute: 45)
        )

        // Then
        #expect(suggestion.configuration == .init(daysBefore: 3, hour: 18, minute: 45))
    }

    @Test func configurationWhenDisabledThenIsNil() {
        // Given / When
        let suggestion = ImportReminderSuggestion(isEnabled: false, daysBefore: 3, time: .mockNine)

        // Then
        #expect(suggestion.configuration == nil)
    }
}
