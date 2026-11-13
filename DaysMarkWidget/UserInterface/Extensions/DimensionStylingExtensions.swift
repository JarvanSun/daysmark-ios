//
//  DimensionStylingExtensions.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import SunUserInterface

extension DimensionStyling {
    var activitySpacing: CGFloat {
        value(for: .activitySpacing, default: 10)
    }

    var activityCountdownMaximumWidth: CGFloat {
        value(for: .activityCountdownMaximumWidth, default: 54)
    }

    var accessoryLineSpacing: CGFloat {
        value(for: .accessoryLineSpacing, default: 1)
    }

    private func value(for dimension: WidgetDimension, default defaultValue: CGFloat) -> CGFloat {
        value(for: DimensionToken(rawValue: dimension.rawValue), default: defaultValue)
    }
}

private enum WidgetDimension: String {
    case activitySpacing
    case activityCountdownMaximumWidth
    case accessoryLineSpacing
}
