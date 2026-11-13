//
//  DimensionStylingExtensions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import SunUserInterface

extension DimensionStyling {
    var placeholderTopInset: CGFloat {
        value(for: .placeholderTopInset, default: 48)
    }

    var placeholderMessageSpacing: CGFloat {
        value(for: .placeholderMessageSpacing, default: 10)
    }

    var emptyArtworkMaximumWidth: CGFloat {
        value(for: .emptyArtworkMaximumWidth, default: 240)
    }

    var filteredArtworkWidth: CGFloat {
        value(for: .filteredArtworkWidth, default: 164)
    }

    var filteredArtworkHeight: CGFloat {
        value(for: .filteredArtworkHeight, default: 110)
    }

    var appearanceChoiceSize: CGFloat {
        value(for: .appearanceChoiceSize, default: 44)
    }

    var primaryButtonMaximumWidth: CGFloat {
        value(for: .primaryButtonMaximumWidth, default: 320)
    }

    var primaryButtonHeight: CGFloat {
        value(for: .primaryButtonHeight, default: 50)
    }

    var shareCardWidth: CGFloat {
        value(for: .shareCardWidth, default: 360)
    }

    var shareCardMinimumHeight: CGFloat {
        value(for: .shareCardMinimumHeight, default: 450)
    }

    var shareCardArtworkHeight: CGFloat {
        value(for: .shareCardArtworkHeight, default: 180)
    }

    var shareCardIconSize: CGFloat {
        value(for: .shareCardIconSize, default: 112)
    }

    var shareCardIconOffset: CGFloat {
        value(for: .shareCardIconOffset, default: 8)
    }

    var shareCardRuleWidth: CGFloat {
        value(for: .shareCardRuleWidth, default: 32)
    }

    private func value(for dimension: EventsDimension, default defaultValue: CGFloat) -> CGFloat {
        value(for: DimensionToken(rawValue: dimension.rawValue), default: defaultValue)
    }
}

private enum EventsDimension: String {
    case placeholderTopInset
    case placeholderMessageSpacing
    case emptyArtworkMaximumWidth
    case filteredArtworkWidth
    case filteredArtworkHeight
    case appearanceChoiceSize
    case primaryButtonMaximumWidth
    case primaryButtonHeight
    case shareCardWidth
    case shareCardMinimumHeight
    case shareCardArtworkHeight
    case shareCardIconSize
    case shareCardIconOffset
    case shareCardRuleWidth
}
