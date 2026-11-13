//
//  TimeOfDay.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation

public struct TimeOfDay: Equatable, Sendable {
    public let hour: Int
    public let minute: Int

    public init(minuteOfDay: Int) {
        let lastMinuteOfDay = 24 * 60 - 1
        let clamped = min(max(minuteOfDay, 0), lastMinuteOfDay)
        hour = clamped / 60
        minute = clamped % 60
    }

    public init(hour: Int, minute: Int) {
        self.init(minuteOfDay: hour * 60 + minute)
    }

    public var minuteOfDay: Int { hour * 60 + minute }
}
