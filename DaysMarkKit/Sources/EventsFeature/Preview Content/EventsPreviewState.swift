//
//  EventsPreviewState.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation

enum EventsPreviewState: String, CaseIterable, CustomStringConvertible {
    case typical
    case singleEvent
    case empty
    case noMatch
    case longTitles
    case german

    var description: String { rawValue }

    var contents: PreviewContents {
        switch self {
        case .typical, .noMatch, .german: .typical
        case .singleEvent: .singleEvent
        case .empty: .empty
        case .longTitles: .longTitles
        }
    }

    var locale: Locale {
        switch self {
        case .german: Locale(identifier: "de_DE")
        case .typical, .singleEvent, .empty, .noMatch, .longTitles:
            Locale(identifier: "en_US")
        }
    }
}

enum PreviewContents {
    case typical
    case singleEvent
    case empty
    case longTitles
}
#endif
