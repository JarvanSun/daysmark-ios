//
//  CountdownSentence.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct CountdownSentence: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions

    let sentence: OnboardingContent.Sentence
    let titleFont: DaysMarkFont
    let phraseFont: DaysMarkFont

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceCompact) {
            Text(sentence.title)
                .textStyle(DaysMarkColor.textPrimary, titleFont)

            CountdownPhrase(count: sentence.count, font: phraseFont)
                .contentTransition(.numericText(countsDown: sentence.count.direction == .upcoming))
                .animation(
                    DaysMarkMotion.countChange.animation(reducingMotion: reduceMotion),
                    value: sentence.count.phrase
                )
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.dimensions) var dimensions

    let content = PreviewObjectPool().onboardingViewModel(.birthday).content

    VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
        if let headline = content.headline {
            CountdownSentence(sentence: headline, titleFont: .heroTitle, phraseFont: .heroPhrase)
        }

        if let detail = content.detail {
            CountdownSentence(sentence: detail, titleFont: .rowTitle, phraseFont: .rowPhrase)
        }
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
