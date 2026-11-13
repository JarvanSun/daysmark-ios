//
//  DetailCountButton.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct DetailCountButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions
    @ScaledMetric(relativeTo: .largeTitle) private var numberScale: CGFloat = 1

    let event: EventItem
    let unit: EventDetailUnit
    let onSwitchUnit: () -> Void

    var body: some View {
        Button(action: onSwitchUnit) {
            TimelineView(.everyMinute) { timeline in
                countBlock(for: unit.count(of: event, at: timeline.date))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.daysmark(.row))
        .animation(DaysMarkMotion.unitChange.animation(reducingMotion: reduceMotion), value: unit)
        .accessibilityHint(Text("detail.count.switchUnitHint", bundle: .module))
    }

    private func countBlock(for count: DetailCount) -> some View {
        VStack(spacing: dimensions.spaceCompact) {
            count.number
                .font(DaysMarkFont.detailNumber.font(scaledBy: numberScale))
                .monospacedDigit()
                .foregroundColor(event.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .contentTransition(.numericText(countsDown: count.countsDown))

            Text(count.caption)
                .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.detailUnit)
                .contentTransition(.opacity)

            if let days = count.remainderDays {
                Text("detail.count.remainder \(days)", bundle: .module)
                    .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.supporting)
            }
        }
    }
}
