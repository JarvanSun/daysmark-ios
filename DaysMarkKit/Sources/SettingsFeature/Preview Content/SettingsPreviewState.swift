//
//  SettingsPreviewState.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation

enum SettingsPreviewState: String, CaseIterable, CustomStringConvertible {
    case typical
    case empty
    case german

    var description: String { rawValue }

    var contents: PreviewContents {
        switch self {
        case .typical, .german: .typical
        case .empty: .builtInOnly
        }
    }

    var locale: Locale {
        switch self {
        case .german: Locale(identifier: "de_DE")
        case .typical, .empty: Locale(identifier: "en_US")
        }
    }

    var editorTarget: CategoryEditorTarget {
        switch self {
        case .typical, .german: .new
        case .empty: .existing(id: UUID(), name: "Travel", icon: "airplane")
        }
    }
}
#endif
