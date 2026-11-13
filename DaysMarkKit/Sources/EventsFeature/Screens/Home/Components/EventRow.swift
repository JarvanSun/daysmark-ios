//
//  EventRow.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/09/02.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct EventRow: View {
    @Environment(\.dimensions) private var dimensions

    let event: EventItem
    let showsDisclosure: Bool

    var body: some View {
        HStack(spacing: dimensions.spaceMedium) {
            EventIcon(event.appearance, size: dimensions.eventIconColumnWidth)
                .frame(width: dimensions.eventIconColumnWidth)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: dimensions.rowLineSpacing) {
                Text(verbatim: event.title)
                    .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.eventTitle)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                DayCountText(event: event, font: .rowPhrase)

                Text(verbatim: event.date)
                    .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.rowSecondary)
            }

            Spacer(minLength: dimensions.spaceMedium)

            if showsDisclosure {
                Image(style: DaysMarkImage.chevronForward)
                    .textStyle(DaysMarkColor.textTertiary, DaysMarkFont.disclosure)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(event.accessibilityLabel)
    }
}

struct DayCountText: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let event: EventItem
    let font: DaysMarkFont

    var body: some View {
        Text(verbatim: event.phrase)
            .textStyle(event.tint, font)
            .monospacedDigit()
            .contentTransition(.numericText(countsDown: event.countsDown))
            .animation(
                DaysMarkMotion.dayChange.animation(reducingMotion: reduceMotion),
                value: event.phrase
            )
    }
}

#if DEBUG
#Preview {
    let pool = PreviewObjectPool()

    List {
        EventRow(event: pool.eventItem, showsDisclosure: true)
    }
    .listStyle(.plain)
    .listSectionSeparator(.hidden)
    .scrollContentBackground(.hidden)
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
