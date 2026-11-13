//
//  EventCalendarSystemExtensions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

extension EventCalendarSystem {
    var title: LocalizedStringResource {
        switch self {
        case .gregorian: LocalizedStringResource("event.calendar.gregorian", bundle: .module)
        case .chinese: LocalizedStringResource("event.calendar.chinese", bundle: .module)
        case .islamicUmmAlQura:
            LocalizedStringResource("event.calendar.islamicUmmAlQura", bundle: .module)
        }
    }
}
