//
//  NotificationPayloadKeyTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import DaysMarkCore

struct NotificationPayloadKeyTests {
    @Test func rawValuesThenKeepTheirShippedValues() {
        #expect(NotificationPayloadKey.eventID.rawValue == "countdown.eventID")
        #expect(NotificationPayloadKey.deepLink.rawValue == "countdown.deepLink")
    }
}
