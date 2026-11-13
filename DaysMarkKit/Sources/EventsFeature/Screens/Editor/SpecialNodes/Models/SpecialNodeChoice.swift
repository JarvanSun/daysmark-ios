//
//  SpecialNodeChoice.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftUI

struct SpecialNodeChoice: Identifiable, Equatable {
    let preset: SpecialNodePreset
    let availability: SpecialNodeAvailability
    let isSelected: Bool
    let hasNotificationTime: Bool

    var id: String { preset.id }

    var canBeSelected: Bool { hasNotificationTime && availability.isAvailable }

    var isEnabled: Bool { canBeSelected || isSelected }
}

extension SpecialNodeChoice {
    var detail: Text? {
        switch (hasNotificationTime, availability.isAvailable, isSelected) {
        case (true, false, false): Text(availability.message)
        default: nil
        }
    }

    var accessibilityValue: LocalizedStringResource {
        switch (canBeSelected, hasNotificationTime) {
        case (true, _):
            LocalizedStringResource("editor.specialNodes.choice.available", bundle: .module)
        case (false, true): availability.message
        case (false, false):
            LocalizedStringResource("editor.specialNodes.choice.needsTime", bundle: .module)
        }
    }

    var opacity: Double { isEnabled ? 1 : 0.5 }

    var accessibilityTraits: AccessibilityTraits {
        isSelected ? .isSelected : []
    }
}
