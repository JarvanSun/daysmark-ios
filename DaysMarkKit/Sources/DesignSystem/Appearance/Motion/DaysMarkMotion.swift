//
//  DaysMarkMotion.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

nonisolated public enum DaysMarkMotion: Equatable, Sendable {
    case focusChange
    case dayChange
    case unitChange
    case directionChange
    case countChange
    case tick
    case onboardingFinish

    public var animation: Animation {
        switch self {
        case .focusChange: .smooth(duration: 0.38)
        case .dayChange: .smooth(duration: 0.45)
        case .unitChange: .smooth(duration: 0.5)
        case .directionChange, .countChange: .smooth(duration: 0.6)
        case .tick: .snappy
        case .onboardingFinish: .smooth(duration: 0.7)
        }
    }

    public func animation(reducingMotion: Bool) -> Animation? {
        reducingMotion ? nil : animation
    }
}
