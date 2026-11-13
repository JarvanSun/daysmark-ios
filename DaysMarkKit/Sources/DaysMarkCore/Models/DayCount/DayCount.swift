//
//  DayCount.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/31.
//

import Foundation

public struct DayCount: Equatable, Sendable {
    public let days: Int
    public let direction: Direction

    public init(days: Int, direction: Direction) {
        self.days = days
        self.direction = direction
    }

    public func accessibilityLabel(title: String) -> String {
        direction == .past
            ? String(localized: "event.accessibility.past \(title) \(days)", bundle: .module)
            : String(localized: "event.accessibility.upcoming \(title) \(days)", bundle: .module)
    }
}

extension DayCount {
    public enum Direction: Equatable, Sendable {
        case upcoming
        case today
        case past
    }
}
