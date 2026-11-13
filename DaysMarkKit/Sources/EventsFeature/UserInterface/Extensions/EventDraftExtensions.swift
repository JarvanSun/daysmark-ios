//
//  EventDraftExtensions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation
import SwiftUI

extension EventDraft {
    var specialNodesSummary: Text {
        switch specialReminderNodes.count {
        case 0: Text("editor.specialNodes.summary.none", bundle: .module)
        case let count: Text(verbatim: count.formatted())
        }
    }

    func dayCount(at now: Date, in userTimeZone: TimeZone) -> DayCount? {
        guard let event = previewEvent(at: now) else { return nil }

        let occurrence = EventOccurrenceResolver().nextOccurrence(
            for: event,
            now: now,
            userTimeZone: userTimeZone
        )

        guard let occurrence else { return nil }

        return DayCountCalculator(calendar: Calendar(identifier: .gregorian)).dayCount(
            targetDate: occurrence.referenceDate(
                now: now,
                semantics: timeSemantics,
                userTimeZone: userTimeZone
            ),
            calendarSystem: calendarSystem,
            countsFromDayOne: countsFromDayOne,
            now: now,
            userTimeZone: userTimeZone
        )
    }
}
