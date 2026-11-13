//
//  DayCountExtensions.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem

extension DayCount {
    var phrase: String {
        RelativeTimePhrase(self).text
    }

    var landscapeMarker: LandscapeMarker? {
        switch direction {
        case .today: nil
        case .past, .upcoming: LandscapeMarker(days: days, isPast: direction == .past)
        }
    }
}

extension DayCount.Direction {
    var tint: DaysMarkColor {
        switch self {
        case .past: .past
        case .today, .upcoming: .upcoming
        }
    }
}
