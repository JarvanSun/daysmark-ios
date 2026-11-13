//
//  OnboardingPrimaryActionTests.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import OnboardingFeature

struct OnboardingPrimaryActionTests {
    @Test(arguments: [
        (OnboardingPrimaryAction.next, "onboarding.action.continue"),
        (.createSelected, "onboarding.action.createSelected"),
        (.startWithBasics, "onboarding.action.startWithBasics"),
    ])
    func titleThenNamesTheAction(action: OnboardingPrimaryAction, key: String) {
        #expect(action.title.key == key)
    }
}
