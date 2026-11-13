//
//  OnboardingHeader.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct OnboardingHeader: View {
    @Environment(\.dimensions) private var dimensions

    let step: OnboardingStep

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            Text(step.title)
                .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.pageTitle)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(step.subtitle)
                .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.pageSubtitle)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.dimensions) var dimensions

    VStack(alignment: .leading, spacing: dimensions.spaceXLarge) {
        OnboardingHeader(step: .welcome)

        OnboardingHeader(step: .birthday)

        OnboardingHeader(step: .quickEvents)
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
