//
//  EditorTarget.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

nonisolated enum EditorTarget: Hashable {
    case new(categoryID: EventCategory.ID)
    case existing(CountdownEvent.ID)

    var eventID: CountdownEvent.ID? {
        switch self {
        case .new: nil
        case .existing(let id): id
        }
    }

    var categoryID: EventCategory.ID {
        switch self {
        case .new(let categoryID): categoryID
        case .existing: BuiltInCategory.important.id
        }
    }
}
