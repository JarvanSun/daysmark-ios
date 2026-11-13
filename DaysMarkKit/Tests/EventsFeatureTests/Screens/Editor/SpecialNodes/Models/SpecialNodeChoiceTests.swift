//
//  SpecialNodeChoiceTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import EventsFeature

struct SpecialNodeChoiceTests {
    @Test func accessibilityValueWithoutANotificationTimeThenAsksForOne() {
        // Given
        let choice = makeChoice(hasNotificationTime: false)

        // Then
        #expect(choice.accessibilityValue.key == "editor.specialNodes.choice.needsTime")
        #expect(choice.detail == nil)
        #expect(!choice.isEnabled)
        #expect(choice.opacity == 0.5)
    }

    @Test func accessibilityValueForAPassedDateThenExplainsWhy() {
        // Given
        let choice = makeChoice(availability: .targetInPast)

        // Then
        #expect(choice.accessibilityValue.key == "editor.specialNodes.availability.passed")
        #expect(choice.detail != nil)
        #expect(!choice.canBeSelected)
    }

    @Test func accessibilityValueForAnAvailableChoiceThenSaysSo() {
        // Given
        let choice = makeChoice()

        // Then
        #expect(choice.accessibilityValue.key == "editor.specialNodes.choice.available")
        #expect(choice.isEnabled)
        #expect(choice.opacity == 1)
    }

    @Test func isEnabledForASelectedChoiceThatPassedThenStaysSoItCanBeRemoved() {
        // Given
        let choice = makeChoice(availability: .targetInPast, isSelected: true)

        // Then
        #expect(choice.isEnabled)
        #expect(choice.detail == nil)
    }

    @Test(arguments: [
        (SpecialReminderNodeKind.beforeDays, 1, "editor.specialNodes.preset.before %lld"),
        (.beforeDays, 7, "editor.specialNodes.preset.before %lld"),
        (.elapsedDays, 100, "editor.specialNodes.preset.elapsed %lld"),
        (.anniversaryYears, 5, "editor.specialNodes.preset.anniversary %lld"),
    ])
    func titleThenDescribesThePreset(kind: SpecialReminderNodeKind, value: Int, key: String) {
        #expect(SpecialNodePreset(kind: kind, value: value).title.key == key)
    }

    @Test func presetsThenOfferTenChoicesInThreeGroups() {
        // Given
        let catalog = SpecialNodeCatalog()

        // Then
        #expect(catalog.presets(of: .beforeDays).map(\.value) == [100, 30, 7, 1])
        #expect(catalog.presets(of: .elapsedDays).map(\.value) == [100, 500, 1_000])
        #expect(catalog.presets(of: .anniversaryYears).map(\.value) == [1, 5, 10])
        #expect(SpecialNodePreset(kind: .beforeDays, value: 7).id == "beforeDays-7")
    }

    private func makeChoice(
        availability: SpecialNodeAvailability = .available,
        isSelected: Bool = false,
        hasNotificationTime: Bool = true
    ) -> SpecialNodeChoice {
        SpecialNodeChoice(
            preset: SpecialNodePreset(kind: .beforeDays, value: 7),
            availability: availability,
            isSelected: isSelected,
            hasNotificationTime: hasNotificationTime
        )
    }
}
