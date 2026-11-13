//
//  EventEditorViewModelSpecialNodesTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import EventsFeature

struct EventEditorViewModelSpecialNodesTests {
    @Test func toggleSpecialNodeThenNeedsANotificationTimeBeforeTheDraftCanBeSaved() {
        // Given
        let viewModel = makeViewModelForATripInThirtyDays()
        let preset = SpecialNodePreset(kind: .beforeDays, value: 7)

        // When
        viewModel.toggleSpecialNode(preset)
        let withoutATime = viewModel.canSave
        viewModel.setSpecialNodeTime(TimeOfDay(hour: 8, minute: 30))
        let withATime = viewModel.canSave
        viewModel.toggleSpecialNode(preset)

        // Then
        #expect(!withoutATime)
        #expect(withATime)
        #expect(viewModel.draft.specialReminderNodes.isEmpty)
        #expect(viewModel.draft.specialNodeNotificationMinuteOfDay == nil)
    }

    @Test func clearSpecialNodesThenRemovesEveryNodeAndTheSharedTime() {
        // Given
        let viewModel = makeViewModelForATripInThirtyDays()
        viewModel.setSpecialNodeTime(TimeOfDay(hour: 9, minute: 0))
        viewModel.toggleSpecialNode(SpecialNodePreset(kind: .beforeDays, value: 7))
        let added = viewModel.draft.specialReminderNodes.count

        // When
        viewModel.clearSpecialNodes()

        // Then
        #expect(added == 1)
        #expect(viewModel.draft.specialReminderNodes.isEmpty)
        #expect(!viewModel.hasSpecialNodeTime)
    }

    @Test func setSpecialNodeTimeThenLetsNodesBeChosen() {
        // Given
        let viewModel = makeViewModelForATripInThirtyDays()
        let withoutATime = viewModel.specialNodeTime

        // When
        viewModel.setSpecialNodeTime(TimeOfDay(hour: 9, minute: 0))
        viewModel.toggleSpecialNode(SpecialNodePreset(kind: .beforeDays, value: 7))
        let choices = viewModel.specialNodeChoices(of: .beforeDays)
        let selectedValues = choices.filter(\.isSelected).map(\.preset.value)
        let allHaveATime = choices.allSatisfy(\.hasNotificationTime)

        // Then
        #expect(withoutATime == TimeOfDay(hour: 9, minute: 0))
        #expect(viewModel.draft.specialNodeNotificationMinuteOfDay == 540)
        #expect(selectedValues == [7])
        #expect(allHaveATime)
        #expect(viewModel.permissionRequest != nil)
        #expect(viewModel.canSave)
    }

    @Test func toggleSpecialNodeTimeThenStartsAtNineAndClearsEveryNodeWhenTurnedOff() {
        // Given
        let viewModel = makeViewModelForATripInThirtyDays()

        // When
        viewModel.toggleSpecialNodeTime(true)
        let turnedOn = viewModel.draft.specialNodeNotificationMinuteOfDay
        viewModel.toggleSpecialNode(SpecialNodePreset(kind: .beforeDays, value: 7))
        viewModel.toggleSpecialNodeTime(false)

        // Then
        #expect(turnedOn == 540)
        #expect(viewModel.draft.specialReminderNodes.isEmpty)
        #expect(!viewModel.hasSpecialNodeTime)
    }

    @Test func toggleSpecialNodeThatHasPassedThenAddsNothing() {
        // Given
        let viewModel = makeViewModelForATripInThirtyDays()
        viewModel.setSpecialNodeTime(TimeOfDay(hour: 9, minute: 0))

        // When
        viewModel.toggleSpecialNode(SpecialNodePreset(kind: .beforeDays, value: 100))

        // Then
        #expect(viewModel.draft.specialReminderNodes.isEmpty)
    }

    @Test func moveTargetDateThenRemovesNodesThatAreNoLongerAvailable() {
        // Given
        let viewModel = makeViewModelForATripInThirtyDays()
        viewModel.setSpecialNodeTime(TimeOfDay(hour: 9, minute: 0))
        viewModel.toggleSpecialNode(SpecialNodePreset(kind: .beforeDays, value: 7))

        // When
        viewModel.moveTargetDate(to: Date.mockNow.addingTimeInterval(86_400 * 2))

        // Then
        #expect(viewModel.draft.specialReminderNodes.isEmpty)
        #expect(!viewModel.hasSpecialNodeTime)
    }

    private func makeViewModelForATripInThirtyDays() -> EventEditorViewModel {
        let viewModel = EventEditorViewModel.mock()
        viewModel.draft.title = "Trip"
        viewModel.moveTargetDate(to: Date.mockNow.addingTimeInterval(86_400 * 30))

        return viewModel
    }
}
