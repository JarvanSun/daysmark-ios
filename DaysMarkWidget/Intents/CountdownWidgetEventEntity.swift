//
//  CountdownWidgetEventEntity.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import DesignSystem
import Foundation

struct CountdownWidgetEventEntity: AppEntity, Sendable {
    static let defaultQuery = CountdownWidgetEventQuery()
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "widget.event.type")

    let id: UUID
    let title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "widget.event.displayTitle \(title)",
            image: DisplayRepresentation.Image(systemName: DaysMarkImage.calendar.rawValue)
        )
    }

    init(_ option: WidgetEventOption) {
        id = option.id
        title = option.title
    }
}
