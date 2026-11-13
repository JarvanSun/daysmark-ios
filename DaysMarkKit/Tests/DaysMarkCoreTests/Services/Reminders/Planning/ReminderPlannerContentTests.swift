//
//  ReminderPlannerContentTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct ReminderPlannerContentTests {
    @Test func userInfoThenCarriesTheEventIDAndItsLink() throws {
        // Given
        let id = try #require(UUID(uuidString: "11111111-2222-4333-8444-555555555555"))
        let event = CountdownEvent.mock(id: id, title: "Launch", year: 2030, month: 8, day: 20)

        // When
        let userInfo = ReminderPlanner().userInfo(for: event)

        // Then
        #expect(
            userInfo == [
                "countdown.eventID": "11111111-2222-4333-8444-555555555555",
                "countdown.deepLink": "daysmark://event/11111111-2222-4333-8444-555555555555",
            ]
        )
    }

    @Test func ordinaryRemindersThenUseTheEventTitleAndItsLink() throws {
        // Given
        let event = CountdownEvent.mock(title: "Visible launch", reminderDays: [0])

        // When
        let planned = try #require(
            ReminderPlanner()
                .ordinaryReminders(for: event, now: .mockNow, userTimeZone: .mockUTC)
                .first
        )

        // Then
        #expect(planned.reminder.title == "Visible launch")
        #expect(planned.reminder.userInfo["countdown.eventID"] == event.id.uuidString)
        #expect(
            planned.reminder.userInfo["countdown.deepLink"]
                == "daysmark://event/\(event.id.uuidString)"
        )
    }
}
