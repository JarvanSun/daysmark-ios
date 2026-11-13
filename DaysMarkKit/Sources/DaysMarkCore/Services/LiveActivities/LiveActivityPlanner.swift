//
//  LiveActivityPlanner.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct LiveActivityPlanner: Sendable {
    var eligibilityWindow: TimeInterval { 60 * 60 }

    var pointEventLinger: TimeInterval { 15 * 60 }

    func plan(
        occurrence: EventOccurrence,
        semantics: EventTimeSemantics,
        now: Date
    ) -> LiveActivityPlan? {
        guard semantics != .floatingAllDay else { return nil }

        return switch occurrence.endDate {
        case let end?: rangePlan(from: occurrence.startDate, to: end, now: now)
        case nil: pointPlan(at: occurrence.startDate, now: now)
        }
    }

    private func rangePlan(from start: Date, to end: Date, now: Date) -> LiveActivityPlan? {
        let isBeforeStart = now < start
        let startsSoon = start.timeIntervalSince(now) <= eligibilityWindow

        return switch (isBeforeStart, startsSoon, now < end) {
        case (true, true, _):
            LiveActivityPlan(
                targetDate: start,
                target: .start,
                terminalDate: end,
                isTerminal: false
            )
        case (false, _, true):
            LiveActivityPlan(targetDate: end, target: .end, terminalDate: end, isTerminal: false)
        default:
            nil
        }
    }

    private func pointPlan(at start: Date, now: Date) -> LiveActivityPlan? {
        let distance = start.timeIntervalSince(now)

        guard distance <= eligibilityWindow, distance >= -pointEventLinger else { return nil }

        return LiveActivityPlan(
            targetDate: start,
            target: .point,
            terminalDate: start.addingTimeInterval(pointEventLinger),
            isTerminal: distance <= 0
        )
    }
}

struct LiveActivityPlan: Equatable, Sendable {
    let targetDate: Date
    let target: ImportantDateActivityAttributes.Target
    let terminalDate: Date
    let isTerminal: Bool
}
