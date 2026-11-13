//
//  CountdownEvent.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation
import SwiftData

@Model
public final class CountdownEvent {
    public internal(set) var id: UUID = UUID()
    var recordID: UUID = UUID()
    public internal(set) var title: String = ""

    var targetYear: Int = 0
    var targetMonth: Int = 1
    var targetDay: Int = 1

    public internal(set) var targetHour: Int?
    var targetMinute: Int?

    var calendarSystemRaw: String = EventCalendarSystem.gregorian.rawValue
    var timeSemanticsRaw: String = EventTimeSemantics.floatingAllDay.rawValue
    var targetEra: Int?
    var targetIsLeapMonth: Bool = false
    var utcOffsetSecondsAtCreation: Int?

    var timeZoneIdentifier: String = TimeZone.current.identifier

    var endYear: Int?
    var endMonth: Int?
    var endDay: Int?
    var endEra: Int?
    var endIsLeapMonth: Bool = false
    var endHour: Int?
    var endMinute: Int?
    var endUTCOffsetSecondsAtCreation: Int?
    var rangeCalendarDaySpan: Int?
    var rangeDurationSeconds: Double?

    var specialNodeNotificationHour: Int?
    var specialNodeNotificationMinute: Int?

    var countsFromDayOne: Bool = false

    public internal(set) var icon: String = ""

    public internal(set) var categoryID: UUID = BuiltInCategory.important.id
    var currentRevisionID: UUID?
    var deletionRevisionID: UUID?
    public internal(set) var deletedAt: Date?

    public internal(set) var permanentDeletionRequestedAt: Date?
    var seedIdentifier: String?
    var isSpotlightHidden: Bool = false
    var sourceKindRaw: String = ImportSourceKind.manual.rawValue
    var snapshotDigest: String?
    var conflictFingerprint: String?

    public internal(set) var repeatRule: RepeatRule = RepeatRule.never

    var storedRepeatInterval: Int?
    var storedRepeatUnit: RepeatUnit?

    public internal(set) var category: EventCategory?

    @Relationship(deleteRule: .cascade, inverse: \ReminderRule.event)
    var reminders: [ReminderRule]?

    @Relationship(deleteRule: .cascade, inverse: \SpecialReminderNode.event)
    var specialReminderNodes: [SpecialReminderNode]?

    var createdAt: Date = Date()

    var updatedAt: Date = Date()

    public init(
        id: UUID = UUID(),
        recordID: UUID = UUID(),
        title: String,
        year: Int,
        month: Int,
        day: Int,
        hour: Int? = nil,
        minute: Int? = nil,
        timeZone: TimeZone,
        endYear: Int? = nil,
        endMonth: Int? = nil,
        endDay: Int? = nil,
        countsFromDayOne: Bool = false,
        icon: String = "",
        repeatRule: RepeatRule = .never,
        repeatInterval: Int = 1,
        repeatUnit: RepeatUnit = .year,
        category: EventCategory? = nil,
        seedIdentifier: String? = nil,
        calendarSystem: EventCalendarSystem = .gregorian,
        timeSemantics: EventTimeSemantics? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        let isTimed = hour != nil && minute != nil
        let inferredSemantics = timeSemantics ?? (isTimed ? .fixedInstant : .floatingAllDay)

        self.id = id
        self.recordID = recordID
        self.title = title
        self.targetYear = year
        self.targetMonth = month
        self.targetDay = day
        self.targetHour = hour
        self.targetMinute = minute
        self.calendarSystemRaw = calendarSystem.rawValue
        self.timeSemanticsRaw = inferredSemantics.rawValue
        self.timeZoneIdentifier = timeZone.identifier
        self.endYear = endYear
        self.endMonth = endMonth
        self.endDay = endDay
        self.countsFromDayOne = countsFromDayOne
        self.icon = icon
        self.repeatRule = repeatRule
        self.storedRepeatInterval = repeatRule.clampedInterval(repeatInterval)
        self.storedRepeatUnit = repeatUnit
        self.category = category
        self.categoryID = category?.id ?? BuiltInCategory.important.id
        self.seedIdentifier = seedIdentifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        deriveDateState(in: timeZone)
    }

    var sourceKind: ImportSourceKind {
        get { ImportSourceKind(rawValue: sourceKindRaw) ?? .manual }
        set { sourceKindRaw = newValue.rawValue }
    }

    var repeatInterval: Int {
        get { repeatRule.clampedInterval(storedRepeatInterval ?? 1) }
        set { storedRepeatInterval = repeatRule.clampedInterval(newValue) }
    }

    var repeatUnit: RepeatUnit {
        get { storedRepeatUnit ?? .year }
        set { storedRepeatUnit = newValue }
    }
}

// MARK: - ImportSourceKind

public enum ImportSourceKind: String, Codable, CaseIterable, Sendable {
    case manual
    case seeded
    case contacts
    case calendar
}
