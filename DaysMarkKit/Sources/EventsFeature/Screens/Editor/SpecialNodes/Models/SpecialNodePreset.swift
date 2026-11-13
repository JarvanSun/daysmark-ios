//
//  SpecialNodePreset.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

struct SpecialNodePreset: Identifiable, Equatable {
    let kind: SpecialReminderNodeKind
    let value: Int

    var id: String { "\(kind.rawValue)-\(value)" }

    func matches(_ node: SpecialReminderNodeDraft) -> Bool {
        node.kind == kind && node.value == value
    }
}

extension SpecialNodePreset {
    var title: LocalizedStringResource {
        switch kind {
        case .beforeDays:
            LocalizedStringResource("editor.specialNodes.preset.before \(value)", bundle: .module)
        case .elapsedDays:
            LocalizedStringResource("editor.specialNodes.preset.elapsed \(value)", bundle: .module)
        case .anniversaryYears:
            LocalizedStringResource(
                "editor.specialNodes.preset.anniversary \(value)",
                bundle: .module
            )
        }
    }
}
