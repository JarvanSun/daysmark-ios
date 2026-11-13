//
//  PinAction.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/09/02.
//

import DaysMarkCore
import DesignSystem
import Foundation

enum PinAction: Equatable {
    case pin(CountdownEvent.ID)
    case unpin

    var pinnedEventID: CountdownEvent.ID? {
        switch self {
        case .pin(let id): id
        case .unpin: nil
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .pin: LocalizedStringResource("event.focus.set", bundle: .module)
        case .unpin: LocalizedStringResource("event.focus.remove", bundle: .module)
        }
    }

    var rowSymbol: DaysMarkImage {
        switch self {
        case .pin: .pin
        case .unpin: .pinSlash
        }
    }

    var toolbarSymbol: DaysMarkImage {
        switch self {
        case .pin: .pin
        case .unpin: .pinFill
        }
    }

    init(for id: CountdownEvent.ID, pinnedEventID: CountdownEvent.ID?) {
        self = pinnedEventID == id ? .unpin : .pin(id)
    }
}
