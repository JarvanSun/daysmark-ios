//
//  Mocks.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import TestSupport

extension Date {
    nonisolated static var mockNow: Date {
        .mock(year: 2026, month: 9, day: 5)
    }

    nonisolated static func mock(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        Calendar.mockGregorianUTC.date(
            from: DateComponents(year: year, month: month, day: day, hour: hour)
        )!
    }
}
