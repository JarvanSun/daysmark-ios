//
//  NotificationPreferences.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation

public struct NotificationPreferences {
    public init() {}

    public var defaultNewReminderTime: TimeOfDay { TimeOfDay(hour: 9, minute: 0) }
}

extension NotificationPreferences {
    public enum Key: String, Sendable {
        case newReminderMinuteOfDay = "notifications.newReminderMinuteOfDay"
    }
}
