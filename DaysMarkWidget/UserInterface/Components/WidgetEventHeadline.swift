//
//  WidgetEventHeadline.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct WidgetEventHeadline<Phrase: View>: View {
    @Environment(\.dimensions) private var dimensions

    private let title: String
    private let emphasis: WidgetEventEmphasis
    private let phrase: () -> Phrase

    init(
        title: String,
        emphasis: WidgetEventEmphasis,
        @ViewBuilder phrase: @escaping () -> Phrase
    ) {
        self.title = title
        self.emphasis = emphasis
        self.phrase = phrase
    }

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceCompact) {
            Text(title)
                .textStyle(DaysMarkColor.textPrimary, titleFont)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            phrase()
                .font(phraseFont)
                .monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var titleFont: DaysMarkFont {
        switch emphasis {
        case .compact, .standard: .widgetTitle
        case .prominent: .widgetProminentTitle
        }
    }

    private var phraseFont: DaysMarkFont {
        switch emphasis {
        case .compact: .rowPhrase
        case .standard, .prominent: .widgetPhrase
        }
    }
}

enum WidgetEventEmphasis: CaseIterable {
    case compact
    case standard
    case prominent
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.dimensions) var dimensions

    VStack(alignment: .leading, spacing: dimensions.spaceLargeSmall) {
        ForEach(WidgetEventEmphasis.allCases, id: \.self) {
            WidgetEventHeadline(title: PreviewObjectPool().rows[0].title, emphasis: $0) {
                WidgetPhraseText(PreviewObjectPool().rows[0].phrase, direction: .upcoming)
            }
        }
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
