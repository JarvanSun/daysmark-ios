//
//  SpecialReminderNodeKindExtensions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

extension SpecialReminderNodeKind {
    var groupTitle: LocalizedStringResource {
        switch self {
        case .beforeDays:
            LocalizedStringResource("editor.specialNodes.group.before", bundle: .module)
        case .elapsedDays:
            LocalizedStringResource("editor.specialNodes.group.elapsed", bundle: .module)
        case .anniversaryYears:
            LocalizedStringResource("editor.specialNodes.group.anniversary", bundle: .module)
        }
    }
}
