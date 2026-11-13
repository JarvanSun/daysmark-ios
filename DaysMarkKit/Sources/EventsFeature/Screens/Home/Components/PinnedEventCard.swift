//
//  PinnedEventCard.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct PinnedEventCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions

    let event: EventItem

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            Text(verbatim: event.title)
                .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.heroTitle)
                .fixedSize(horizontal: false, vertical: true)

            DayCountText(event: event, font: .heroPhrase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, dimensions.spaceSmall)
        .contentShape(Rectangle())
        .animation(
            DaysMarkMotion.focusChange.animation(reducingMotion: reduceMotion),
            value: event.id
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(event.accessibilityLabel)
    }
}

#if DEBUG
#Preview {
    PinnedEventCard(event: PreviewObjectPool().eventItem)
        .padding()
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
