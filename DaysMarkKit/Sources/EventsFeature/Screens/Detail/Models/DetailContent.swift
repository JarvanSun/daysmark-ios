//
//  DetailContent.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

struct DetailContent {
    let event: EventItem?
    let pinAction: PinAction
    let unit: EventDetailUnit
    let conflictVersions: [EventConflictVersion]
    let nextChange: Date?

    var isDeleted: Bool {
        event == nil
    }

    var hasConflicts: Bool {
        !conflictVersions.isEmpty
    }

    var canSwitchUnit: Bool {
        switch event?.direction {
        case .upcoming, .past: true
        case .today, nil: false
        }
    }

    var tickerTarget: Date? {
        canSwitchUnit ? event?.counted.resolvedOccurrenceDate : nil
    }
}
