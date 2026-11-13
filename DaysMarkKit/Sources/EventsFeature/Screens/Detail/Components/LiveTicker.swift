//
//  LiveTicker.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/10/07.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct LiveTicker: View {
    @Environment(\.locale) private var locale

    let target: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            Text(verbatim: remainingTime(at: timeline.date))
                .font(DaysMarkFont.detailTicker)
                .monospacedDigit()
                .contentTransition(.numericText())
                .animation(
                    DaysMarkMotion.tick.animation,
                    value: Int(timeline.date.timeIntervalSince1970)
                )
        }
        .accessibilityHidden(true)
    }

    private func remainingTime(at date: Date) -> String {
        Duration.seconds(Int(abs(target.timeIntervalSince(date)))).formatted(
            .units(
                allowed: [.days, .hours, .minutes, .seconds],
                width: .narrow,
                zeroValueUnits: .show(length: 1)
            )
            .locale(locale)
        )
    }
}

#if DEBUG
#Preview {
    LiveTicker(target: PreviewObjectPool().now)
        .padding()
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
