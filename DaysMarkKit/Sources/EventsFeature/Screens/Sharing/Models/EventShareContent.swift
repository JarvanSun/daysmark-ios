//
//  EventShareContent.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/09/03.
//

import DaysMarkCore
import DesignSystem
import Foundation

struct EventShareContent: Equatable {
    let title: String
    let relativeTime: String
    let absoluteTime: String
    let calendarName: String?
    let referenceDateText: String
    let appearance: EventAppearance
    let direction: DayCount.Direction
    let category: String?

    var plainText: String {
        [title, relativeTime, absoluteTime, calendarName, category, referenceDateText]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }
}
