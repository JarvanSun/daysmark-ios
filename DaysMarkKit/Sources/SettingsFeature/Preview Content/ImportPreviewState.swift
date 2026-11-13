//
//  ImportPreviewState.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation

enum ImportPreviewState: String, CaseIterable, CustomStringConvertible {
    case notScanned
    case review
    case nothingFound
    case german

    var description: String { rawValue }

    var isScanned: Bool {
        switch self {
        case .notScanned: false
        case .review, .nothingFound, .german: true
        }
    }

    var hasResults: Bool {
        switch self {
        case .review, .german: true
        case .notScanned, .nothingFound: false
        }
    }

    var locale: Locale {
        switch self {
        case .german: Locale(identifier: "de_DE")
        case .notScanned, .review, .nothingFound: Locale(identifier: "en_US")
        }
    }
}
#endif
