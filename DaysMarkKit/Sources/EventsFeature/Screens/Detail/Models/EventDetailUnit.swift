//
//  EventDetailUnit.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

enum EventDetailUnit: CaseIterable {
    case days
    case weeks
    case hours
    case minutes

    var next: EventDetailUnit {
        switch self {
        case .days: .weeks
        case .weeks: .hours
        case .hours: .minutes
        case .minutes: .days
        }
    }

    var followsTheClock: Bool {
        switch self {
        case .days, .weeks: false
        case .hours, .minutes: true
        }
    }

    func count(of event: EventItem, at date: Date) -> DetailCount {
        let days = event.counted.dayCount.days
        let now = followsTheClock ? date : event.now

        return DetailCount(
            direction: event.direction,
            unit: self,
            value: value(days: days, target: event.counted.resolvedOccurrenceDate, now: now),
            remainderDays: remainderDays(days: days)
        )
    }

    func value(days: Int, target: Date?, now: Date) -> Int {
        switch self {
        case .days: days
        case .weeks: days / daysPerWeek
        case .hours: Int(seconds(days: days, target: target, now: now) / secondsPerHour)
        case .minutes: Int(seconds(days: days, target: target, now: now) / secondsPerMinute)
        }
    }

    private func seconds(days: Int, target: Date?, now: Date) -> Double {
        target.map { abs($0.timeIntervalSince(now)) } ?? Double(days) * secondsPerDay
    }

    private var secondsPerDay: Double { 86_400 }

    private var secondsPerHour: Double { 3_600 }

    private var secondsPerMinute: Double { 60 }

    func remainderDays(days: Int) -> Int? {
        guard self == .weeks, days % daysPerWeek != 0 else { return nil }

        return days % daysPerWeek
    }

    private var daysPerWeek: Int { 7 }
}
