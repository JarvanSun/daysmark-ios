//
//  OnboardingStepTests.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import OnboardingFeature

struct OnboardingStepTests {
    @Test(arguments: [
        (OnboardingStep.welcome, "onboarding.welcome.title"),
        (.birthday, "onboarding.birthday.title"),
        (.quickEvents, "onboarding.seeds.title"),
    ])
    func titleThenNamesTheStep(step: OnboardingStep, key: String) {
        #expect(step.title.key == key)
    }

    @Test(arguments: [
        (OnboardingStep.birthday, "onboarding.birthday.message"),
        (.quickEvents, "onboarding.seeds.message"),
    ])
    func subtitleThenExplainsTheStep(step: OnboardingStep, key: String) {
        #expect(step.subtitle.key == key)
    }
}
