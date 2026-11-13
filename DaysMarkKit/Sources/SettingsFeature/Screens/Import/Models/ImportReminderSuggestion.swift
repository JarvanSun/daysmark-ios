//
//  ImportReminderSuggestion.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DaysMarkCore

struct ImportReminderSuggestion: Equatable {
    var isEnabled: Bool
    var daysBefore: Int
    var time: TimeOfDay

    var configuration: ImportReminderConfiguration? {
        isEnabled
            ? ImportReminderConfiguration(
                daysBefore: daysBefore,
                hour: time.hour,
                minute: time.minute
            ) : nil
    }
}
