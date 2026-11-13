//
//  AppRequestInboxTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import DaysMark

struct AppRequestInboxTests {
    @Test func takePendingRequestThenReturnsAHeldRequestOnce() throws {
        // Given
        let inbox = AppRequestInbox()
        let eventID = try #require(UUID(uuidString: "AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA"))

        // When
        inbox.hold(.event(eventID))
        let first = inbox.takePendingRequest()
        let second = inbox.takePendingRequest()

        // Then
        #expect(first == .event(eventID))
        #expect(second == nil)
        #expect(inbox.pendingRequest == nil)
    }
}
