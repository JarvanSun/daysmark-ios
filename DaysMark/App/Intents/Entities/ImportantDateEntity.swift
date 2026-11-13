//
//  ImportantDateEntity.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import CoreSpotlight
import DaysMarkCore
import Foundation
import UniformTypeIdentifiers

struct ImportantDateEntity: IndexedEntity, Sendable {
    static let defaultQuery = ImportantDateEntityQuery()
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "intent.event.type"

    let id: UUID

    @Property(title: "intent.event.property.title", indexingKey: \.title)
    var title: String

    @Property(title: "intent.event.property.date", indexingKey: \.startDate)
    var date: Date

    @Property(title: "intent.event.property.category")
    var category: String

    init(_ match: EventMatch) {
        id = match.id
        title = match.title
        date = match.date
        category = match.categoryName
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "intent.event.displayTitle \(title)",
            subtitle:
                "intent.event.displaySubtitle \(date.formatted(date: .abbreviated, time: .shortened))"
        )
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = defaultAttributeSet
        attributes.contentType = UTType.data.identifier
        attributes.contentURL = AppRequest.event(id).url

        return attributes
    }
}
