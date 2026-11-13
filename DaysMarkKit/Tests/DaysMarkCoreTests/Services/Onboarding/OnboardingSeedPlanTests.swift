//
//  OnboardingSeedPlanTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct OnboardingSeedPlanTests {
    @Test(arguments: [
        (OnboardingSeed.newYear, EventCalendarSystem.gregorian),
        (.fallbackNewYear, .gregorian),
        (.nextMonth, .chinese),
        (.monthEnd, .chinese),
        (.fallbackYearProgress, .chinese),
    ])
    func eventSeedThenUsesTheUserCalendarExceptForTheGregorianNewYear(
        seed: OnboardingSeed,
        expected: EventCalendarSystem
    ) throws {
        // Given
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = .mockUTC
        let plan = OnboardingSeedPlan(calendar: chinese, now: .mock(2026, 9, 3))

        // When
        let eventSeed = try plan.eventSeed(for: seed, birthday: nil)

        // Then
        #expect(eventSeed.date.calendarSystem == expected)
    }

    @Test(arguments: [
        (OnboardingSeed.newYear, 2027, 1, 1),
        (.nextMonth, 2026, 10, 1),
        (.monthEnd, 2026, 9, 30),
        (.fallbackYearProgress, 2026, 1, 1),
        (.birthday, 1991, 2, 14),
        (.birthDate, 1991, 2, 14),
    ])
    func eventSeedThenPlacesEachSeedOnItsDay(
        seed: OnboardingSeed,
        year: Int,
        month: Int,
        day: Int
    ) throws {
        // Given
        let plan = OnboardingSeedPlan(calendar: .mockGregorianUTC, now: .mock(2026, 9, 3))

        // When
        let eventSeed = try plan.eventSeed(
            for: seed,
            birthday: BirthdayCandidate(date: .mock(1991, 2, 14))
        )

        // Then
        #expect(eventSeed.id == seed.eventID)
        #expect(eventSeed.identifier == seed.rawValue)
        #expect(eventSeed.date.year == year)
        #expect(eventSeed.date.month == month)
        #expect(eventSeed.date.day == day)
    }

    @Test(arguments: [OnboardingSeed.birthday, .birthDate])
    func eventSeedWithoutABirthdayThenThrowsInvalidBirthday(seed: OnboardingSeed) {
        // Given
        let plan = OnboardingSeedPlan(calendar: .mockGregorianUTC, now: .mockNow)

        // When / Then
        #expect(throws: OnboardingError.invalidBirthday) {
            try plan.eventSeed(for: seed, birthday: nil)
        }
    }

    @Test
    func eventThenIsTheUnsavedEventOfTheSeed() throws {
        // Given
        let plan = OnboardingSeedPlan(calendar: .mockGregorianUTC, now: .mock(2026, 9, 3))

        // When
        let event = try plan.event(for: .monthEnd, birthday: nil)

        // Then
        #expect(event.id == OnboardingSeed.monthEnd.eventID)
        #expect(event.seedIdentifier == OnboardingSeed.monthEnd.rawValue)
        #expect(event.repeatRule == .monthlyLastDay)
        #expect(event.targetDay == 30)
        #expect(event.modelContext == nil)
    }
}
