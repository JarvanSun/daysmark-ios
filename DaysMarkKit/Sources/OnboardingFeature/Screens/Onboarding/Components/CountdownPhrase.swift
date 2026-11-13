//
//  CountdownPhrase.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct CountdownPhrase: View {
    let count: DayCount
    let font: DaysMarkFont

    var body: some View {
        Text(verbatim: count.phrase)
            .textStyle(count.direction.tint, font)
            .monospacedDigit()
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.dimensions) var dimensions

    VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
        CountdownPhrase(count: DayCount(days: 50, direction: .upcoming), font: .rowPhrase)

        CountdownPhrase(count: DayCount(days: 9_812, direction: .past), font: .rowPhrase)
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
