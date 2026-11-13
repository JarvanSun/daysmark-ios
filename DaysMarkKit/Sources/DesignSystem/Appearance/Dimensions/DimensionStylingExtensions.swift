//
//  DimensionStylingExtensions.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import SunUserInterface

extension DimensionStyling {
    public var pageMargin: CGFloat {
        value(for: .pageMargin, default: 20)
    }

    public var spaceCompact: CGFloat {
        value(for: .spaceCompact, default: 4)
    }

    public var minimumTapTarget: CGFloat {
        value(for: .minimumTapTarget, default: 44)
    }

    public var rowMinimumHeight: CGFloat {
        value(for: .rowMinimumHeight, default: 52)
    }

    public var iconColumnWidth: CGFloat {
        value(for: .iconColumnWidth, default: 28)
    }

    public var eventIconColumnWidth: CGFloat {
        value(for: .eventIconColumnWidth, default: 36)
    }

    var landscapeHeight: CGFloat {
        value(for: .landscapeHeight, default: 96)
    }

    public var rowLineSpacing: CGFloat {
        value(for: .rowLineSpacing, default: 2)
    }

    var confettiPieceMinimumSize: CGFloat {
        value(for: .confettiPieceMinimumSize, default: 6)
    }

    var confettiPieceMaximumSize: CGFloat {
        value(for: .confettiPieceMaximumSize, default: 13)
    }

    var confettiSway: CGFloat {
        value(for: .confettiSway, default: 22)
    }

    var confettiEntryOffset: CGFloat {
        value(for: .confettiEntryOffset, default: 20)
    }

    public var todayMarkerSize: CGFloat {
        value(for: .todayMarkerSize, default: 8)
    }

    public var sidebarMinimumWidth: CGFloat {
        value(for: .sidebarMinimumWidth, default: 320)
    }

    public var sidebarIdealWidth: CGFloat {
        value(for: .sidebarIdealWidth, default: 420)
    }

    public var sidebarMaximumWidth: CGFloat {
        value(for: .sidebarMaximumWidth, default: 520)
    }

    public var settingsSeparatorInset: CGFloat {
        iconColumnWidth + spaceMedium
    }
}

private extension DimensionStyling {
    func value(for dimension: DaysMarkDimension, default defaultValue: CGFloat) -> CGFloat {
        value(for: DimensionToken(rawValue: dimension.rawValue), default: defaultValue)
    }
}

private enum DaysMarkDimension: String {
    case pageMargin
    case spaceCompact
    case minimumTapTarget
    case rowMinimumHeight
    case iconColumnWidth
    case eventIconColumnWidth
    case landscapeHeight
    case rowLineSpacing
    case confettiPieceMinimumSize
    case confettiPieceMaximumSize
    case confettiSway
    case confettiEntryOffset
    case todayMarkerSize
    case sidebarMinimumWidth
    case sidebarIdealWidth
    case sidebarMaximumWidth
}
