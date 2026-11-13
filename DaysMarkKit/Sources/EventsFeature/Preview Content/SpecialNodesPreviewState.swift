//
//  SpecialNodesPreviewState.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation

enum SpecialNodesPreviewState: String, CaseIterable, CustomStringConvertible {
    case notConfigured
    case configured
    case german

    var description: String { rawValue }

    var hasNotificationTime: Bool {
        switch self {
        case .notConfigured: false
        case .configured, .german: true
        }
    }

    var locale: Locale {
        switch self {
        case .german: Locale(identifier: "de_DE")
        case .notConfigured, .configured: Locale(identifier: "en_US")
        }
    }
}
#endif
