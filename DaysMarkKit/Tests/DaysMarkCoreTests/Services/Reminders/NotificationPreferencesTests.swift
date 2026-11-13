//
//  NotificationPreferencesTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct NotificationPreferencesTests {
    @Test func keysThenKeepTheirShippedValues() {
        #expect(
            NotificationPreferences.Key.newReminderMinuteOfDay.rawValue
                == "notifications.newReminderMinuteOfDay"
        )
    }

    @Test func defaultNewReminderTimeThenIsNineInTheMorning() {
        #expect(NotificationPreferences().defaultNewReminderTime.minuteOfDay == 540)
    }
}
