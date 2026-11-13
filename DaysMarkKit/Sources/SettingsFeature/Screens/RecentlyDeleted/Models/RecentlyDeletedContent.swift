//
//  RecentlyDeletedContent.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation
import SwiftUI

struct RecentlyDeletedContent {
    var rows: [Row] = []

    var rowIDs: Set<CountdownEvent.ID> {
        Set(rows.map(\.id))
    }
}

extension RecentlyDeletedContent {
    struct Row: Identifiable, Equatable {
        let id: CountdownEvent.ID
        let title: String
        let deletedAt: Date
        let isHighlighted: Bool

        var background: Color {
            isHighlighted ? DaysMarkColor.tintSoft.color : .clear
        }
    }
}
