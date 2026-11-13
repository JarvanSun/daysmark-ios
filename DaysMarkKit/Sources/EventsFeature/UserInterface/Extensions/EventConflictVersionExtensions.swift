//
//  EventConflictVersionExtensions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

extension EventConflictVersion {
    var title: String { draft.trimmedTitle }

    var date: String {
        var calendar = Calendar(identifier: draft.calendarSystem.identifier)
        calendar.timeZone = draft.timeZone

        return draft.targetDate.formatted(
            Date.FormatStyle(
                date: .long,
                time: draft.timeSemantics == .floatingAllDay ? .omitted : .shortened,
                calendar: calendar,
                timeZone: draft.timeZone
            )
        )
    }

    var changedAt: LocalizedStringResource {
        LocalizedStringResource(
            "detail.conflict.changedAt \(createdAt.formatted(date: .abbreviated, time: .shortened))",
            bundle: .module
        )
    }
}
