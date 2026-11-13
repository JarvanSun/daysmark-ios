//
//  DayCountExtensions.swift
//  DaysMarkWidget
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
