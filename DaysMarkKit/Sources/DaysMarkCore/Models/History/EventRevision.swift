//
//  EventRevision.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/01.
//

import Foundation
import SwiftData

@Model
public final class EventRevision {
    public internal(set) var id: UUID = UUID()
    var recordID: UUID = UUID()
    public internal(set) var eventID: UUID = UUID()
    var parentRevisionID: UUID?
    var conflictGroupID: UUID = UUID()
    var supersededRevisionIDs: [UUID] = []
    var restoredDeletionRevisionID: UUID?
    var createdAt: Date = Date()
    var isDeletion: Bool = false
    var isPermanentDeletionRequest: Bool = false

    var title: String = ""
    var targetYear: Int = 0
    var targetMonth: Int = 1
    var targetDay: Int = 1
    var targetHour: Int?
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
    var ordinaryReminderSnapshotData: Data?
    var specialNodeSnapshotData: Data?
    var countsFromDayOne: Bool = false
    var icon: String = ""
    var repeatRule: RepeatRule = RepeatRule.never
    var repeatInterval: Int = 1
    var repeatUnit: RepeatUnit = RepeatUnit.year
    var categoryID: UUID = BuiltInCategory.important.id
    var isSpotlightHidden: Bool = false
    var sourceKindRaw: String = ImportSourceKind.manual.rawValue
    var snapshotDigest: String?
    var conflictFingerprint: String?

    init(
        id: UUID = UUID(),
        recordID: UUID = UUID(),
        eventID: UUID,
        parentRevisionID: UUID?,
        conflictGroupID: UUID,
        supersededRevisionIDs: [UUID] = [],
        restoredDeletionRevisionID: UUID? = nil,
        createdAt: Date,
        isDeletion: Bool = false,
        isPermanentDeletionRequest: Bool = false,
        event: CountdownEvent
    ) {
        self.id = id
        self.recordID = recordID
        self.eventID = eventID
        self.parentRevisionID = parentRevisionID
        self.conflictGroupID = conflictGroupID
        self.supersededRevisionIDs = supersededRevisionIDs
        self.restoredDeletionRevisionID = restoredDeletionRevisionID
        self.createdAt = createdAt
        self.isDeletion = isDeletion
        self.isPermanentDeletionRequest = isPermanentDeletionRequest
        self.title = event.title
        self.targetYear = event.targetYear
        self.targetMonth = event.targetMonth
        self.targetDay = event.targetDay
        self.targetHour = event.targetHour
        self.targetMinute = event.targetMinute
        self.calendarSystemRaw = event.calendarSystemRaw
        self.timeSemanticsRaw = event.timeSemanticsRaw
        self.targetEra = event.targetEra
        self.targetIsLeapMonth = event.targetIsLeapMonth
        self.utcOffsetSecondsAtCreation = event.utcOffsetSecondsAtCreation
        self.timeZoneIdentifier = event.timeZoneIdentifier
        self.endYear = event.endYear
        self.endMonth = event.endMonth
        self.endDay = event.endDay
        self.endEra = event.endEra
        self.endIsLeapMonth = event.endIsLeapMonth
        self.endHour = event.endHour
        self.endMinute = event.endMinute
        self.endUTCOffsetSecondsAtCreation = event.endUTCOffsetSecondsAtCreation
        self.rangeCalendarDaySpan = event.rangeCalendarDaySpan
        self.rangeDurationSeconds = event.rangeDurationSeconds
        self.specialNodeNotificationHour = event.specialNodeNotificationHour
        self.specialNodeNotificationMinute = event.specialNodeNotificationMinute
        self.ordinaryReminderSnapshotData = EventRevisionSnapshotEncoder().ordinaryReminders(
            for: event
        )
        self.specialNodeSnapshotData = EventRevisionSnapshotEncoder().specialNodes(for: event)
        self.countsFromDayOne = event.countsFromDayOne
        self.icon = event.icon
        self.repeatRule = event.repeatRule
        self.repeatInterval = event.repeatInterval
        self.repeatUnit = event.repeatUnit
        self.categoryID = event.categoryID
        self.isSpotlightHidden = event.isSpotlightHidden
        self.sourceKindRaw = event.sourceKindRaw
        self.snapshotDigest = event.snapshotDigest
        self.conflictFingerprint = event.conflictFingerprint
    }

    func snapshotEvent(in userTimeZone: TimeZone, at date: Date) -> CountdownEvent {
        let snapshot = CountdownEvent(
            title: title,
            year: targetYear,
            month: targetMonth,
            day: targetDay,
            hour: targetHour,
            minute: targetMinute,
            timeZone: TimeZone(identifier: timeZoneIdentifier) ?? userTimeZone,
            endYear: endYear,
            endMonth: endMonth,
            endDay: endDay,
            countsFromDayOne: countsFromDayOne,
            icon: icon,
            repeatRule: repeatRule,
            repeatInterval: repeatInterval,
            repeatUnit: repeatUnit,
            calendarSystem: EventCalendarSystem(rawValue: calendarSystemRaw) ?? .gregorian,
            timeSemantics: EventTimeSemantics(rawValue: timeSemanticsRaw) ?? .floatingAllDay,
            createdAt: date,
            updatedAt: date
        )
        snapshot.targetEra = targetEra
        snapshot.targetIsLeapMonth = targetIsLeapMonth
        snapshot.utcOffsetSecondsAtCreation = utcOffsetSecondsAtCreation
        snapshot.endEra = endEra
        snapshot.endIsLeapMonth = endIsLeapMonth
        snapshot.endHour = endHour
        snapshot.endMinute = endMinute
        snapshot.endUTCOffsetSecondsAtCreation = endUTCOffsetSecondsAtCreation
        snapshot.rangeCalendarDaySpan = rangeCalendarDaySpan
        snapshot.rangeDurationSeconds = rangeDurationSeconds
        snapshot.specialNodeNotificationHour = specialNodeNotificationHour
        snapshot.specialNodeNotificationMinute = specialNodeNotificationMinute
        snapshot.categoryID = categoryID
        snapshot.isSpotlightHidden = isSpotlightHidden

        return snapshot
    }
}
