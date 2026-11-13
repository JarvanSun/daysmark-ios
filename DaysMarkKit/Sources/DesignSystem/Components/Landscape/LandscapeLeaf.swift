//
//  LandscapeLeaf.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics

enum LandscapeLeaf: CaseIterable, Identifiable {
    case near
    case middle
    case far

    var id: Self { self }

    var size: CGFloat {
        switch self {
        case .near: 8
        case .middle: 6
        case .far: 4
        }
    }

    var rotation: Double {
        switch self {
        case .near: 12
        case .middle: -24
        case .far: 32
        }
    }

    var opacity: Double {
        switch self {
        case .near: 0.8
        case .middle: 0.6
        case .far: 0.4
        }
    }

    var offset: CGPoint {
        switch self {
        case .near: CGPoint(x: 15, y: -2)
        case .middle: CGPoint(x: 28, y: 1)
        case .far: CGPoint(x: 40, y: 9)
        }
    }
}
