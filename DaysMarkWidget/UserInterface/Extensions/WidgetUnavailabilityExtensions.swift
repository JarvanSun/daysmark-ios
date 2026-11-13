//
//  WidgetUnavailabilityExtensions.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation

extension WidgetUnavailability {
    var title: String {
        switch self {
        case .noEvents: String(localized: "widget.notice.empty.title")
        case .missingSource: String(localized: "widget.notice.unavailable.title")
        }
    }

    var detail: String {
        switch self {
        case .noEvents: String(localized: "widget.notice.empty.message")
        case .missingSource: String(localized: "widget.notice.unavailable.message")
        }
    }

    var symbol: DaysMarkImage {
        switch self {
        case .noEvents: .calendarBadgePlus
        case .missingSource: .exclamationmarkTriangle
        }
    }
}
