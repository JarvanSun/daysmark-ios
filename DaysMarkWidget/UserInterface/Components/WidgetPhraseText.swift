//
//  WidgetPhraseText.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI
import WidgetKit

struct WidgetPhraseText: View {
    @Environment(\.locale) private var locale
    @Environment(\.widgetRenderingMode) private var renderingMode

    private let phrase: RelativeTimePhrase
    private let direction: DayCount.Direction

    init(_ phrase: RelativeTimePhrase, direction: DayCount.Direction) {
        self.phrase = phrase
        self.direction = direction
    }

    var body: some View {
        text
            .foregroundStyle(foreground)
            .widgetAccentable()
    }

    @ViewBuilder
    private var text: some View {
        switch phrase.targetDate {
        case nil:
            Text(verbatim: phrase.text)
        case _?:
            TimelineView(.periodic(from: .now, by: secondsBetweenUpdates)) { context in
                Text(verbatim: phrase.updated(at: context.date, locale: locale).text)
            }
        }
    }

    private var secondsBetweenUpdates: TimeInterval { 60 }

    private var foreground: Color {
        switch renderingMode {
        case .fullColor: direction.tint.color
        default: .primary
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.dimensions) var dimensions

    VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
        ForEach(PreviewObjectPool().rows) { row in
            WidgetPhraseText(row.phrase, direction: row.direction)
                .font(DaysMarkFont.rowPhrase)
                .monospacedDigit()
        }
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
