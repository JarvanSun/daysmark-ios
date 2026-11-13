//
//  OnboardingActionBar.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct OnboardingActionBar: View {
    @Environment(\.dimensions) private var dimensions

    let action: OnboardingPrimaryAction
    let isSaving: Bool
    let onPerform: () -> Void

    var body: some View {
        Button(action: onPerform) {
            Group {
                switch isSaving {
                case true: ProgressView()
                case false: Text(action.title)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.daysmark(.bar))
        .disabled(isSaving)
        .padding(.horizontal, dimensions.pageMargin)
        .padding(.top, dimensions.spaceLargeSmall)
        .padding(.bottom, dimensions.spaceSmall)
    }
}

#if DEBUG
#Preview {
    VStack {
        OnboardingActionBar(action: .next, isSaving: false, onPerform: {})

        OnboardingActionBar(action: .createSelected, isSaving: false, onPerform: {})

        OnboardingActionBar(action: .startWithBasics, isSaving: false, onPerform: {})

        OnboardingActionBar(action: .next, isSaving: true, onPerform: {})
    }
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
