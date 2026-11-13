//
//  EventsDestination.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import SunUserInterface

nonisolated enum EventsDestination: FeatureDestination {
    case root
    case detail(CountdownEvent.ID, fromFocus: Bool)
    case settings(SettingsPage)
    case editor(EditorTarget)
    case specialNodes
    case sharing(CountdownEvent.ID)

    func shows(sameScreenAs other: EventsDestination) -> Bool {
        switch (self, other) {
        case (.detail(let id, _), .detail(let otherID, _)): id == otherID
        default: self == other
        }
    }
}
