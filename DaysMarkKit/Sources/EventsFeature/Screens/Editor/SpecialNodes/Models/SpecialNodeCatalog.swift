//
//  SpecialNodeCatalog.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

struct SpecialNodeCatalog {
    func presets(of kind: SpecialReminderNodeKind) -> [SpecialNodePreset] {
        values(of: kind).map { SpecialNodePreset(kind: kind, value: $0) }
    }

    private func values(of kind: SpecialReminderNodeKind) -> [Int] {
        switch kind {
        case .beforeDays: [100, 30, 7, 1]
        case .elapsedDays: [100, 500, 1_000]
        case .anniversaryYears: [1, 5, 10]
        }
    }
}
