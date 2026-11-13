//
//  OnboardingContentTests.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SwiftUI
import Testing

@testable import OnboardingFeature

struct OnboardingContentTests {
    @Test(arguments: [(true, DaysMarkImage.checkmarkCircleFill), (false, .circle)])
    func markSymbolThenShowsWhetherTheCandidateIsSelected(isSelected: Bool, symbol: DaysMarkImage) {
        #expect(makeCandidate(isSelected: isSelected).markSymbol == symbol)
    }

    @Test(arguments: [(true, 1), (false, 0.55)])
    func opacityThenDimsAnUnselectedCandidate(isSelected: Bool, opacity: Double) {
        #expect(makeCandidate(isSelected: isSelected).opacity == opacity)
    }

    @Test(arguments: [true, false])
    func accessibilityTraitsThenAnnounceSelection(isSelected: Bool) {
        #expect(
            makeCandidate(isSelected: isSelected).accessibilityTraits.contains(.isSelected)
                == isSelected
        )
    }

    private func makeCandidate(isSelected: Bool) -> OnboardingContent.Candidate {
        OnboardingContent.Candidate(
            seed: .newYear,
            isSelected: isSelected,
            dayCount: nil,
            showsSeparator: false
        )
    }
}
