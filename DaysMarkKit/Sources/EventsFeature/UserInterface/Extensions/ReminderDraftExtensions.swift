//
//  ReminderDraftExtensions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

extension ReminderDraft {
    var time: TimeOfDay {
        TimeOfDay(hour: hour, minute: minute)
    }

    var dayOffsetTitle: String {
        dayOffsetDescription(daysBefore)
    }

    var minuteOffsetTitle: String {
        exactOffsetDescription(minutesBefore ?? 0)
    }
}
