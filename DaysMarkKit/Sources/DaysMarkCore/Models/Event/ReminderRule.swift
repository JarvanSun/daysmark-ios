//
//  ReminderRule.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation
import SwiftData

@Model
final class ReminderRule {
    var id: UUID = UUID()
    var recordID: UUID = UUID()
    var eventID: UUID = UUID()

    var kindRaw: String?

    var minutesBefore: Int?

    var daysBefore: Int = 0
    var hour: Int = 9
    var minute: Int = 0

    var event: CountdownEvent?

    init(
        id: UUID = UUID(),
        recordID: UUID = UUID(),
        eventID: UUID = UUID(),
        kind: ReminderRuleKind = .allDayOffsetAtTime,
        minutesBefore: Int? = nil,
        daysBefore: Int = 0,
        hour: Int = 9,
        minute: Int = 0
    ) {
        self.id = id
        self.recordID = recordID
        self.eventID = eventID
        self.kindRaw = kind.rawValue
        self.minutesBefore = minutesBefore
        self.daysBefore = daysBefore
        self.hour = hour
        self.minute = minute
    }

    var kind: ReminderRuleKind {
        get { kindRaw.flatMap(ReminderRuleKind.init(rawValue:)) ?? .allDayOffsetAtTime }
        set { kindRaw = newValue.rawValue }
    }
}

public enum ReminderRuleKind: String, Codable, CaseIterable, Sendable {
    case allDayOffsetAtTime
    case exactTimeOffset
}
