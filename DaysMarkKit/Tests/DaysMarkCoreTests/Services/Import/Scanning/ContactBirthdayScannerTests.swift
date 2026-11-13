//
//  ContactBirthdayScannerTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct ContactBirthdayScannerTests {
    @Test(arguments: [
        (DateComponents(month: 2, day: 29), DateComponents(year: 2024, month: 2, day: 29)),
        (DateComponents(month: 4, day: 8), DateComponents(year: 2026, month: 4, day: 8)),
        (
            DateComponents(year: 1991, month: 2, day: 14),
            DateComponents(year: 1991, month: 2, day: 14)
        ),
    ])
    func birthdayDateThenKeepsTheDayAndFindsAYearForABirthdayWithoutOne(
        birthday: DateComponents,
        expected: DateComponents
    ) throws {
        // Given
        let calendar = Calendar.mockGregorianUTC

        // When
        let date = try #require(
            ContactBirthdayScanner().birthdayDate(
                birthday,
                calendar: calendar,
                now: .mock(2026, 10, 7)
            )
        )

        // Then
        #expect(calendar.dateComponents([.year, .month, .day], from: date) == expected)
    }

    @Test
    func birthdayDateWhenTheDayDoesNotExistInItsYearThenIsNil() {
        // Given
        let leapDayOfACommonYear = DateComponents(year: 2026, month: 2, day: 29)

        // When
        let date = ContactBirthdayScanner().birthdayDate(
            leapDayOfACommonYear,
            calendar: .mockGregorianUTC,
            now: .mock(2026, 10, 7)
        )

        // Then
        #expect(date == nil)
    }
}
