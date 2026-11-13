//
//  SettingsDestination.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import SunUserInterface

nonisolated enum SettingsDestination: FeatureDestination {
    case root
    case notifications
    case categories
    case categoryEditor(CategoryEditorTarget)
    case importDates
    case widgets
    case siriAndShortcuts
    case recentlyDeleted(highlighting: UUID?)

    init(_ page: SettingsPage) {
        switch page {
        case .root: self = .root
        case .widgets: self = .widgets
        case .recentlyDeleted(let eventID): self = .recentlyDeleted(highlighting: eventID)
        }
    }
}
