//
//  DaysMarkFont.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI
import UIKit

nonisolated public enum DaysMarkFont: CaseIterable, FontStyling {
    case pageTitle
    case heroTitle
    case heroPhrase
    case detailTitle
    case detailNumber
    case detailUnit
    case detailTicker
    case previewNumber
    case previewUnit
    case placeholderTitle
    case headline
    case eventTitle
    case rowTitle
    case rowPhrase
    case rowSecondary
    case supporting
    case sectionTitle
    case pageSubtitle
    case previewSentence
    case footnote
    case selectionMark
    case badgeSymbol
    case filterLabel
    case filterLabelSelected
    case previewSentenceEmphasis
    case buttonLabel
    case noticeTitle
    case linkLabel
    case footnoteEmphasized
    case fineprint
    case actionLabel
    case rowIcon
    case disclosure
    case prominentSymbol
    case widgetTitle
    case widgetProminentTitle
    case widgetPhrase
    case widgetRowTitle
    case widgetCaption
    case widgetSymbol
    case activityCountdown

    public var size: CGFloat {
        switch self {
        case .detailNumber: detailNumberSize
        default: uiFont.pointSize
        }
    }

    public var lineHeight: CGFloat { uiFont.lineHeight }

    public var nativeLineHeight: CGFloat { uiFont.lineHeight }

    public var relativeTo: Font.TextStyle {
        switch self {
        case .pageTitle, .detailNumber: .largeTitle
        case .heroTitle, .previewNumber: .title
        case .heroPhrase, .detailTitle, .activityCountdown: .title2
        case .detailUnit, .detailTicker, .placeholderTitle, .prominentSymbol: .title3
        case .widgetProminentTitle: .title3
        case .headline, .widgetTitle, .widgetPhrase: .headline
        case .eventTitle, .rowTitle, .actionLabel, .rowIcon: .body
        case .pageSubtitle, .previewSentence, .selectionMark, .previewSentenceEmphasis: .body
        case .buttonLabel, .noticeTitle: .body
        case .rowPhrase, .rowSecondary, .supporting, .widgetRowTitle: .subheadline
        case .filterLabel, .filterLabelSelected, .linkLabel: .subheadline
        case .sectionTitle, .footnote, .footnoteEmphasized, .disclosure: .footnote
        case .previewUnit, .widgetCaption: .caption
        case .fineprint, .widgetSymbol, .badgeSymbol: .caption2
        }
    }

    public var font: Font {
        switch self {
        case .pageTitle: .largeTitle.weight(.bold)
        case .heroTitle: .title.weight(.semibold)
        case .heroPhrase, .detailTitle: .title2.weight(.semibold)
        case .detailNumber: .system(size: detailNumberSize, weight: .heavy, design: .rounded)
        case .detailUnit, .placeholderTitle, .widgetProminentTitle: .title3.weight(.semibold)
        case .detailTicker: .system(.title3, design: .monospaced, weight: .medium)
        case .previewNumber: .system(.title, design: .rounded, weight: .heavy)
        case .previewUnit: .caption.weight(.semibold)
        case .headline, .widgetTitle: .headline
        case .eventTitle, .buttonLabel, .noticeTitle: .body.weight(.medium)
        case .rowTitle, .pageSubtitle, .previewSentence: .body
        case .rowIcon: .body.weight(.regular)
        case .actionLabel, .selectionMark, .previewSentenceEmphasis: .body.weight(.semibold)
        case .rowPhrase, .widgetRowTitle, .linkLabel: .subheadline.weight(.medium)
        case .filterLabel: .subheadline
        case .filterLabelSelected: .subheadline.weight(.semibold)
        case .rowSecondary, .supporting: .subheadline
        case .sectionTitle, .disclosure: .footnote.weight(.semibold)
        case .footnote: .footnote
        case .footnoteEmphasized: .footnote.weight(.medium)
        case .fineprint, .widgetSymbol, .badgeSymbol: .caption2
        case .prominentSymbol: .title3
        case .widgetPhrase: .headline.weight(.medium)
        case .widgetCaption: .caption
        case .activityCountdown: .title2.bold()
        }
    }

    public var uiFont: UIFont {
        UIFont.preferredFont(forTextStyle: uiTextStyle)
    }

    public func font(scaledBy scale: CGFloat) -> Font {
        switch self {
        case .detailNumber: .system(size: size * scale, weight: .heavy, design: .rounded)
        default: font
        }
    }
}

nonisolated private extension DaysMarkFont {
    var detailNumberSize: CGFloat { 104 }

    var uiTextStyle: UIFont.TextStyle {
        switch relativeTo {
        case .largeTitle: .largeTitle
        case .title: .title1
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .callout: .callout
        case .footnote: .footnote
        case .caption: .caption1
        case .caption2: .caption2
        default: .body
        }
    }
}

#if DEBUG
#Preview("Fonts") {
    @Previewable @Environment(\.dimensions) var dimensions

    ScrollView {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            ForEach(DaysMarkFont.allCases, id: \.self) { font in
                Text(verbatim: "\(font) 1,024")
                    .textStyle(DaysMarkColor.textPrimary, font)
            }
        }
        .padding()
    }
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
