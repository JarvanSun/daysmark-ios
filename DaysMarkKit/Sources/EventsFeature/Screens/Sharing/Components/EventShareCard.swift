//
//  EventShareCard.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct EventShareCard: View {
    @Environment(\.dimensions) private var dimensions

    let content: EventShareContent

    var body: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            artwork

            eventSummary

            referenceDateFooter
        }
        .multilineTextAlignment(.center)
        .padding(dimensions.spaceXXLarge)
        .frame(maxWidth: .infinity, minHeight: dimensions.shareCardMinimumHeight)
        .background(DaysMarkColor.canvas)
        .environment(\.colorScheme, .light)
        .environment(\.dynamicTypeSize, .large)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(content.plainText)
    }

    private var artwork: some View {
        ZStack {
            Image(.shareBotanical)
                .resizable()
                .scaledToFit()
                .blendMode(.multiply)

            EventIcon(content.appearance, size: dimensions.shareCardIconSize)
                .offset(y: dimensions.shareCardIconOffset)
        }
        .frame(height: dimensions.shareCardArtworkHeight)
        .accessibilityHidden(true)
    }

    private var eventSummary: some View {
        VStack(spacing: dimensions.spaceMedium) {
            Text(verbatim: content.title)
                .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.heroTitle)

            Text(verbatim: content.relativeTime)
                .textStyle(content.direction.tint, DaysMarkFont.heroPhrase)

            dates

            footnote(content.category)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, dimensions.spaceSmall)
    }

    private var dates: some View {
        VStack(spacing: dimensions.spaceCompact) {
            Text(verbatim: content.absoluteTime)
                .font(DaysMarkFont.supporting)

            footnote(content.calendarName)
        }
        .foregroundColor(DaysMarkColor.textSecondary)
    }

    private var referenceDateFooter: some View {
        VStack(spacing: dimensions.spaceMedium) {
            Rectangle()
                .fill(DaysMarkColor.separator.color)
                .frame(width: dimensions.shareCardRuleWidth, height: dimensions.borderWidthSmall)
                .accessibilityHidden(true)

            Text(verbatim: content.referenceDateText)
                .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.fineprint)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func footnote(_ text: String?) -> some View {
        if let text {
            Text(verbatim: text)
                .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.footnote)
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        ForEach(PreviewObjectPool().shareContents, id: \.title) { content in
            EventShareCard(content: content)
                .frame(width: 360)
        }
    }
}
#endif
