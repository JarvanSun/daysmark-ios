//
//  EventDraftValidation.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension EventDraft {
    public var isValid: Bool {
        !trimmedTitle.isEmpty
            && dateSpecificationIsValid
            && rangeIsValid
            && remindersAreValid
            && specialRemindersAreValid
    }

    private var dateSpecificationIsValid: Bool {
        guard let targetDateSpecification else { return false }

        return targetDateSpecification.resolvedDate(
            semantics: timeSemantics,
            eventTimeZone: eventTimeZone,
            userTimeZone: timeZone
        ) != nil
    }

    private var rangeIsValid: Bool {
        endDate == nil || rangeMeasure != nil
    }

    private var remindersAreValid: Bool {
        switch timeSemantics {
        case .floatingAllDay:
            reminders.allSatisfy {
                $0.kind == .allDayOffsetAtTime
                    && $0.daysBefore >= 0
                    && (0..<24).contains($0.hour)
                    && (0..<60).contains($0.minute)
            }
        case .fixedInstant, .floatingLocalTime:
            reminders.allSatisfy {
                $0.kind == .exactTimeOffset && ($0.minutesBefore ?? -1) >= 0
            }
        }
    }

    private var specialRemindersAreValid: Bool {
        guard specialReminderNodes.allSatisfy({ $0.value > 0 }) else { return false }
        guard specialReminderNodes.isEmpty || specialNodeNotificationMinuteOfDay != nil else {
            return false
        }

        return dateSpecificationIsValid
    }
}
