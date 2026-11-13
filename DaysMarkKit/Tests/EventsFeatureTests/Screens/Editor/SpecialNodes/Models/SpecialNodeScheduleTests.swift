//
//  SpecialNodeScheduleTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import EventsFeature

struct SpecialNodeScheduleTests {
    @Test(arguments: [
        (SpecialReminderNodeKind.beforeDays, 7, SpecialNodeAvailability.available),
        (.beforeDays, 100, .targetInPast),
        (.elapsedDays, 100, .available),
        (.anniversaryYears, 1, .available),
    ])
    func availabilityForAnEventInThirtyDaysThenFollowsTheNotificationDate(
        kind: SpecialReminderNodeKind,
        value: Int,
        expected: SpecialNodeAvailability
    ) {
        // Given
        let schedule = makeSchedule(daysFromNow: 30, minuteOfDay: 540)

        // When
        let availability = schedule.availability(of: SpecialNodePreset(kind: kind, value: value))

        // Then
        #expect(availability == expected)
    }

    @Test func availabilityWithoutANotificationTimeThenOnlyNeedsADay() {
        // Given
        let schedule = makeSchedule(daysFromNow: 30, minuteOfDay: nil)

        // Then
        #expect(
            schedule.availability(of: SpecialNodePreset(kind: .beforeDays, value: 100))
                == .available
        )
    }

    @Test func availabilityForARepeatingEventThenUsesItsNextOccurrence() {
        // Given
        let schedule = makeSchedule(daysFromNow: -30, minuteOfDay: 540, repeatRule: .yearly)

        // Then
        #expect(
            schedule.availability(of: SpecialNodePreset(kind: .beforeDays, value: 7)) == .available
        )
        #expect(
            schedule.availability(of: SpecialNodePreset(kind: .elapsedDays, value: 7))
                == .noFutureOccurrence
        )
    }

    @Test func availabilityForALeapDayAnniversaryThenIsInvalidInACommonYear() {
        // Given
        var draft = EventDraft.mock("Leap", on: .mock(2028, 2, 29, hour: 12))
        draft.specialNodeNotificationMinuteOfDay = 540
        let schedule = SpecialNodeSchedule(draft: draft, now: .mockNow, userTimeZone: .gmt)

        // Then
        #expect(
            schedule.availability(of: SpecialNodePreset(kind: .anniversaryYears, value: 1))
                == .invalidDate
        )
    }

    private func makeSchedule(
        daysFromNow: Double,
        minuteOfDay: Int?,
        repeatRule: RepeatRule = .never
    ) -> SpecialNodeSchedule {
        var draft = EventDraft.mock(
            on: Date.mockNow.addingTimeInterval(86_400 * daysFromNow),
            repeating: repeatRule
        )
        draft.specialNodeNotificationMinuteOfDay = minuteOfDay

        return SpecialNodeSchedule(draft: draft, now: .mockNow, userTimeZone: .gmt)
    }
}
