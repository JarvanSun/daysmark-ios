//
//  DetailCount.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import SwiftUI

struct DetailCount: Equatable {
    let direction: DayCount.Direction
    let unit: EventDetailUnit
    let value: Int
    let remainderDays: Int?
}

extension DetailCount {
    var number: Text {
        switch direction {
        case .today: Text("detail.count.today", bundle: .module)
        case .upcoming, .past: Text(verbatim: value.formatted())
        }
    }

    var countsDown: Bool { direction != .past }

    var caption: LocalizedStringResource {
        switch (direction, unit, value == 1) {
        case (.today, _, _): LocalizedStringResource("detail.count.caption.today", bundle: .module)
        case (.upcoming, .days, true):
            LocalizedStringResource("detail.count.caption.upcoming.day", bundle: .module)
        case (.upcoming, .days, false):
            LocalizedStringResource("detail.count.caption.upcoming.days", bundle: .module)
        case (.upcoming, .weeks, true):
            LocalizedStringResource("detail.count.caption.upcoming.week", bundle: .module)
        case (.upcoming, .weeks, false):
            LocalizedStringResource("detail.count.caption.upcoming.weeks", bundle: .module)
        case (.upcoming, .hours, true):
            LocalizedStringResource("detail.count.caption.upcoming.hour", bundle: .module)
        case (.upcoming, .hours, false):
            LocalizedStringResource("detail.count.caption.upcoming.hours", bundle: .module)
        case (.upcoming, .minutes, true):
            LocalizedStringResource("detail.count.caption.upcoming.minute", bundle: .module)
        case (.upcoming, .minutes, false):
            LocalizedStringResource("detail.count.caption.upcoming.minutes", bundle: .module)
        case (.past, .days, true):
            LocalizedStringResource("detail.count.caption.past.day", bundle: .module)
        case (.past, .days, false):
            LocalizedStringResource("detail.count.caption.past.days", bundle: .module)
        case (.past, .weeks, true):
            LocalizedStringResource("detail.count.caption.past.week", bundle: .module)
        case (.past, .weeks, false):
            LocalizedStringResource("detail.count.caption.past.weeks", bundle: .module)
        case (.past, .hours, true):
            LocalizedStringResource("detail.count.caption.past.hour", bundle: .module)
        case (.past, .hours, false):
            LocalizedStringResource("detail.count.caption.past.hours", bundle: .module)
        case (.past, .minutes, true):
            LocalizedStringResource("detail.count.caption.past.minute", bundle: .module)
        case (.past, .minutes, false):
            LocalizedStringResource("detail.count.caption.past.minutes", bundle: .module)
        }
    }
}
