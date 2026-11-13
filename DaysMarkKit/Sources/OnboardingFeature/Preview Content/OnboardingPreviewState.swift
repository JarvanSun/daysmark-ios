//
//  OnboardingPreviewState.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation

enum OnboardingPreviewState: String, CaseIterable, CustomStringConvertible {
    case welcome
    case birthday
    case candidates
    case german

    var description: String { rawValue }

    var stepsTaken: Int {
        switch self {
        case .welcome: 0
        case .birthday: 1
        case .candidates, .german: 2
        }
    }

    var locale: Locale {
        switch self {
        case .german: Locale(identifier: "de_DE")
        case .welcome, .birthday, .candidates: Locale(identifier: "en_US")
        }
    }
}
#endif
