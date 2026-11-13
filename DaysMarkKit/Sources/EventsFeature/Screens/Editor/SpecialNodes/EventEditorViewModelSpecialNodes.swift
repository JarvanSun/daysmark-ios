//
//  EventEditorViewModelSpecialNodes.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

extension EventEditorViewModel {
    var hasSpecialNodeTime: Bool {
        draft.specialNodeNotificationMinuteOfDay != nil
    }

    var specialNodeTime: TimeOfDay {
        TimeOfDay(minuteOfDay: draft.specialNodeNotificationMinuteOfDay ?? defaultNodeMinuteOfDay)
    }

    private var defaultNodeMinuteOfDay: Int { 9 * 60 }

    func specialNodeChoices(of kind: SpecialReminderNodeKind) -> [SpecialNodeChoice] {
        let schedule = nodeSchedule()

        return SpecialNodeCatalog().presets(of: kind).map { preset in
            SpecialNodeChoice(
                preset: preset,
                availability: schedule.availability(of: preset),
                isSelected: contains(preset),
                hasNotificationTime: hasSpecialNodeTime
            )
        }
    }

    func toggleSpecialNodeTime(_ isOn: Bool) {
        switch isOn {
        case true: setSpecialNodeTime(specialNodeTime)
        case false: clearSpecialNodes()
        }
    }

    func setSpecialNodeTime(_ time: TimeOfDay) {
        draft.specialNodeNotificationMinuteOfDay = time.minuteOfDay
        removeUnavailableSpecialNodes()
    }

    func toggleSpecialNode(_ preset: SpecialNodePreset) {
        switch (contains(preset), nodeSchedule().availability(of: preset).isAvailable) {
        case (true, _): remove(preset)
        case (false, true): add(preset)
        case (false, false): break
        }
    }

    private func remove(_ preset: SpecialNodePreset) {
        draft.specialReminderNodes.removeAll(where: preset.matches)
        clearNodeTimeWhenNoNodeIsLeft()
    }

    private func add(_ preset: SpecialNodePreset) {
        draft.specialReminderNodes.append(
            SpecialReminderNodeDraft(kind: preset.kind, value: preset.value)
        )
        askForNotificationPermission()
    }

    func clearSpecialNodes() {
        draft.specialReminderNodes.removeAll()
        draft.specialNodeNotificationMinuteOfDay = nil
    }

    func removeUnavailableSpecialNodes() {
        guard !draft.specialReminderNodes.isEmpty else { return }

        draft.specialReminderNodes = draft.specialReminderNodes.filter(isAvailable)
        clearNodeTimeWhenNoNodeIsLeft()
    }

    func canKeep(_ node: SpecialReminderNodeDraft) -> Bool {
        initialDraft.specialReminderNodes.contains { $0.id == node.id } || isAvailable(node)
    }

    private func nodeSchedule() -> SpecialNodeSchedule {
        SpecialNodeSchedule(draft: draft, now: now(), userTimeZone: calendar.timeZone)
    }

    private func contains(_ preset: SpecialNodePreset) -> Bool {
        draft.specialReminderNodes.contains(where: preset.matches)
    }

    private func isAvailable(_ node: SpecialReminderNodeDraft) -> Bool {
        nodeSchedule()
            .availability(of: SpecialNodePreset(kind: node.kind, value: node.value))
            .isAvailable
    }

    private func clearNodeTimeWhenNoNodeIsLeft() {
        guard draft.specialReminderNodes.isEmpty else { return }

        draft.specialNodeNotificationMinuteOfDay = nil
    }
}
