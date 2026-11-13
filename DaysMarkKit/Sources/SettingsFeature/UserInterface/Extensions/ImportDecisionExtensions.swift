//
//  ImportDecisionExtensions.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SwiftUI

extension ImportDecision {
    var isImportable: Bool {
        switch self {
        case .create, .change, .conflict: true
        case .unchanged, .deleted: false
        }
    }

    var status: LocalizedStringResource {
        switch self {
        case .create: LocalizedStringResource("settings.import.decision.new", bundle: .module)
        case .change: LocalizedStringResource("settings.import.decision.changed", bundle: .module)
        case .conflict:
            LocalizedStringResource("settings.import.decision.conflict", bundle: .module)
        case .unchanged:
            LocalizedStringResource("settings.import.decision.unchanged", bundle: .module)
        case .deleted: LocalizedStringResource("settings.import.decision.deleted", bundle: .module)
        }
    }

    var statusColor: DaysMarkColor {
        switch self {
        case .create, .change: .tint
        case .conflict, .unchanged, .deleted: .textSecondary
        }
    }

    var statusSymbol: DaysMarkImage? {
        switch self {
        case .conflict: .exclamationmarkTriangle
        case .create, .change, .unchanged, .deleted: nil
        }
    }
}
