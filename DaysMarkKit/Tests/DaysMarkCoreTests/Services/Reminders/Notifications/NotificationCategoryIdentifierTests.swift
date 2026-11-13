//
//  NotificationCategoryIdentifierTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import DaysMarkCore

struct NotificationCategoryIdentifierTests {
    @Test func rawValuesThenKeepTheirShippedValues() {
        #expect(NotificationCategoryIdentifier.reminder.rawValue == "countdownReminder")
    }
}
