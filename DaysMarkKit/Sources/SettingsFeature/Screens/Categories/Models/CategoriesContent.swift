//
//  CategoriesContent.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

struct CategoriesContent {
    var rows: [Row] = []

    func order(moving offsets: IndexSet, to destination: Int) -> [EventCategory.ID] {
        let moved = offsets.map { rows[$0].id }
        let kept = rows.indices.filter { !offsets.contains($0) }
        let insertion = kept.count(where: { $0 < destination })
        var order = kept.map { rows[$0].id }
        order.insert(contentsOf: moved, at: insertion)

        return order
    }
}

extension CategoriesContent {
    struct Row: Identifiable, Equatable {
        let id: EventCategory.ID
        let name: String
        let icon: String
        let isBuiltIn: Bool
        let hasEvents: Bool
    }
}

extension CategoriesContent.Row {
    init(_ category: EventCategory) {
        self.init(
            id: category.id,
            name: category.displayName,
            icon: category.icon,
            isBuiltIn: category.isBuiltIn,
            hasEvents: category.events?.isEmpty == false
        )
    }
}
