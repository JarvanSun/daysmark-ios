//
//  DayCountExtensions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import DesignSystem

extension DayCount.Direction {
    var tint: DaysMarkColor {
        switch self {
        case .past: .past
        case .today, .upcoming: .upcoming
        }
    }
}

extension DayCount {
    var landscapeMarker: LandscapeMarker? {
        switch direction {
        case .today: nil
        case .past, .upcoming: LandscapeMarker(days: days, isPast: direction == .past)
        }
    }
}
