//
//  ImportantDateCategoryEntity.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct ImportantDateCategoryEntity: AppEntity, Sendable {
    static let defaultQuery = ImportantDateCategoryQuery()
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "intent.category.type"

    let id: UUID
    let name: String

    init(_ match: CategoryMatch) {
        id = match.id
        name = match.name
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "intent.category.displayTitle \(name)")
    }
}
