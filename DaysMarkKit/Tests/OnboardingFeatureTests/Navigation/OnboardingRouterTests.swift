//
//  OnboardingRouterTests.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import OnboardingFeature

struct OnboardingRouterTests {
    @Test func finishOnboardingThenTellsTheApp() {
        // Given
        var completions = 0
        let router = OnboardingRouter(onComplete: { completions += 1 })

        // When
        router.finishOnboarding()

        // Then
        #expect(completions == 1)
        #expect(router.path.isEmpty)
        #expect(router.presentation == nil)
    }
}
