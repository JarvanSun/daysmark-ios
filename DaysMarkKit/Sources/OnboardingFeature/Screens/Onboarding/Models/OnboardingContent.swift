//
//  OnboardingContent.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import DesignSystem
import SwiftUI

struct OnboardingContent {
    let headline: Sentence?
    let detail: Sentence?
    let horizon: [DayCount]
    let candidates: [Candidate]
    let primaryAction: OnboardingPrimaryAction
    let celebratesBirthday: Bool
}

extension OnboardingContent {
    struct Sentence {
        let title: LocalizedStringResource
        let count: DayCount
    }

    struct Candidate: Identifiable {
        let seed: OnboardingSeed
        let isSelected: Bool
        let dayCount: DayCount?
        let showsSeparator: Bool

        var id: OnboardingSeed { seed }

        var markSymbol: DaysMarkImage {
            isSelected ? .checkmarkCircleFill : .circle
        }

        var markColor: DaysMarkColor {
            isSelected ? .tint : .textTertiary
        }

        var opacity: Double {
            isSelected ? 1 : 0.55
        }

        var accessibilityTraits: AccessibilityTraits {
            isSelected ? .isSelected : []
        }
    }
}
