//
//  EventDraft.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation

public struct EventDraft: Equatable, Sendable {
    public var title = ""
    public var targetDate: Date
    public var endDate: Date?
    public var calendarSystem: EventCalendarSystem = .gregorian
    public var timeSemantics: EventTimeSemantics = .floatingAllDay
    public var islamicObservationConfirmed = false
    public var countsFromDayOne = false
    public var repeatRule: RepeatRule = .never
    public var icon = "star"
    public var isSpotlightHidden = false
    public var categoryID: UUID?
    public var reminders: [ReminderDraft] = []
    public var specialReminderNodes: [SpecialReminderNodeDraft] = []
    public var specialNodeNotificationMinuteOfDay: Int?
    public internal(set) var timeZone: TimeZone

    var repeatInterval = 1
    var repeatUnit: RepeatUnit = .year
    var baseRevisionID: UUID?

    public var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public init(startingOn targetDate: Date, categoryID: UUID?, timeZone: TimeZone) {
        self.targetDate = targetDate
        self.categoryID = categoryID
        self.timeZone = timeZone
    }

    public mutating func removeReminders(atOffsets offsets: IndexSet) {
        for index in offsets.reversed() {
            reminders.remove(at: index)
        }
    }

    public mutating func timeSemanticsChanged() {
        reminders = reminders.map {
            var copy = $0

            switch timeSemantics {
            case .floatingAllDay:
                copy.kind = .allDayOffsetAtTime
                copy.minutesBefore = nil
            case .fixedInstant, .floatingLocalTime:
                copy.kind = .exactTimeOffset
                copy.minutesBefore = copy.minutesBefore ?? 0
            }

            return copy
        }
    }
}
