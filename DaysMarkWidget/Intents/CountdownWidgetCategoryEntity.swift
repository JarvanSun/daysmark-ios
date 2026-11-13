//
//  CountdownWidgetCategoryEntity.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct CountdownWidgetCategoryEntity: AppEntity, Sendable {
    static let defaultQuery = CountdownWidgetCategoryQuery()
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "widget.category.type")

    let id: UUID
    let name: String
    let icon: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "widget.category.displayTitle \(name)",
            image: DisplayRepresentation.Image(systemName: icon)
        )
    }

    init(_ option: WidgetCategoryOption) {
        id = option.id
        name = option.name
        icon = option.icon
    }
}
