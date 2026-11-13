//
//  ReminderDraft.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct ReminderDraft: Identifiable, Equatable, Sendable {
    public var id: UUID = UUID()
    public var kind: ReminderRuleKind = .allDayOffsetAtTime
    public var minutesBefore: Int?
    public var daysBefore: Int = 0
    public var hour: Int = 9
    public var minute: Int = 0

    public init(
        id: UUID = UUID(),
        kind: ReminderRuleKind = .allDayOffsetAtTime,
        minutesBefore: Int? = nil,
        daysBefore: Int = 0,
        hour: Int = 9,
        minute: Int = 0
    ) {
        self.id = id
        self.kind = kind
        self.minutesBefore = minutesBefore
        self.daysBefore = daysBefore
        self.hour = hour
        self.minute = minute
    }

    public var dayOffsetChoices: [Int] { [0, 1, 3, 7, 30] }

    public var exactOffsetChoices: [Int] { [0, 5, 15, 30, 60, 24 * 60] }

    public func dayOffsetDescription(_ days: Int) -> String {
        switch days {
        case 0: String(localized: "reminder.dayOffset.onTheDay", bundle: .module)
        default: String(localized: "reminder.dayOffset.before \(days)", bundle: .module)
        }
    }

    public func exactOffsetDescription(_ minutes: Int) -> String {
        switch minutes {
        case 0: String(localized: "reminder.timeOffset.atEventTime", bundle: .module)
        case 60: String(localized: "reminder.timeOffset.hourBefore", bundle: .module)
        case 1_440: String(localized: "reminder.timeOffset.dayBefore", bundle: .module)
        default: String(localized: "reminder.timeOffset.minutesBefore \(minutes)", bundle: .module)
        }
    }

    func rule(for event: CountdownEvent) -> ReminderRule {
        ReminderRule(
            id: id,
            eventID: event.id,
            kind: kind,
            minutesBefore: minutesBefore,
            daysBefore: daysBefore,
            hour: hour,
            minute: minute
        )
    }
}

public struct SpecialReminderNodeDraft: Identifiable, Equatable, Sendable {
    public var id: UUID = UUID()
    public var kind: SpecialReminderNodeKind
    public var value: Int

    public init(id: UUID = UUID(), kind: SpecialReminderNodeKind, value: Int) {
        self.id = id
        self.kind = kind
        self.value = value
    }
}
