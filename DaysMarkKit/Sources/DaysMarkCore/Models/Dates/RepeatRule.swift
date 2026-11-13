//
//  RepeatRule.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation

public enum RepeatRule: String, Codable, CaseIterable, Sendable {
    case never

    case yearly

    case monthly

    case monthlyLastDay

    case currentYearStart

    case custom
}

extension RepeatRule {
    public var editorCases: [RepeatRule] {
        let offered: [RepeatRule] = [.never, .monthly, .yearly]

        return switch offered.contains(self) {
        case true: offered
        case false: offered + [self]
        }
    }

    public var displayName: String {
        switch self {
        case .never: String(localized: "repeat.never", bundle: .module)
        case .yearly: String(localized: "repeat.yearly", bundle: .module)
        case .monthly: String(localized: "repeat.monthly", bundle: .module)
        case .monthlyLastDay: String(localized: "repeat.monthlyLastDay", bundle: .module)
        case .currentYearStart: String(localized: "repeat.currentYearStart", bundle: .module)
        case .custom: String(localized: "repeat.custom", bundle: .module)
        }
    }

    var intervalRange: ClosedRange<Int> { 1...99 }

    func clampedInterval(_ interval: Int) -> Int {
        min(max(interval, intervalRange.lowerBound), intervalRange.upperBound)
    }
}

public enum RepeatUnit: String, Codable, CaseIterable, Sendable {
    case day
    case week
    case month
    case year
}
