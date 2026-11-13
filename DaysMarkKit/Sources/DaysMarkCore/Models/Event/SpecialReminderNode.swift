//
//  SpecialReminderNode.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation
import SwiftData

@Model
final class SpecialReminderNode {
    var id: UUID = UUID()
    var recordID: UUID = UUID()
    var eventID: UUID = UUID()
    var kindRaw: String = SpecialReminderNodeKind.beforeDays.rawValue
    var value: Int = 1
    var event: CountdownEvent?

    init(
        id: UUID = UUID(),
        recordID: UUID = UUID(),
        eventID: UUID = UUID(),
        kind: SpecialReminderNodeKind,
        value: Int
    ) {
        self.id = id
        self.recordID = recordID
        self.eventID = eventID
        self.kindRaw = kind.rawValue
        self.value = value
    }

    var kind: SpecialReminderNodeKind {
        get { SpecialReminderNodeKind(rawValue: kindRaw) ?? .beforeDays }
        set { kindRaw = newValue.rawValue }
    }
}

public enum SpecialReminderNodeKind: String, Codable, CaseIterable, Sendable {
    case beforeDays
    case elapsedDays
    case anniversaryYears
}
