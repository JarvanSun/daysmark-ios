//
//  ImportCandidate.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

struct ImportCandidate: Identifiable, Equatable {
    let result: ImportResult
    let isSelected: Bool
    let resolution: ImportResolution
    let reminder: ImportReminderSuggestion?

    var id: ImportResult.ID { result.id }

    var needsResolution: Bool {
        result.decision == .conflict && isSelected
    }

    var offeredReminder: ImportReminderSuggestion? {
        result.decision == .create && isSelected ? reminder : nil
    }
}
