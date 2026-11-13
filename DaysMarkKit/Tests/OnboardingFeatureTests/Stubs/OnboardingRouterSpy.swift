//
//  OnboardingRouterSpy.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

@testable import OnboardingFeature

final class OnboardingRouterSpy: OnboardingRouting {
    private(set) var finishCount = 0

    func finishOnboarding() {
        finishCount += 1
    }
}
