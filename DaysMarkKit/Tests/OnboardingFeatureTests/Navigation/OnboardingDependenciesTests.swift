//
//  OnboardingDependenciesTests.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import TestSupport
import Testing

@testable import OnboardingFeature

struct OnboardingDependenciesTests {
    @Test func makeViewModelThenStartsOnWelcomeWithTheBirthdayAtTheStartOf2000() {
        // Given
        let dependencies = OnboardingDependencies(
            completer: OnboardingCompleterSpy(),
            calendar: .mockGregorianUTC,
            now: { .mockNow },
            onComplete: {}
        )

        // When
        let viewModel = dependencies.makeViewModel(router: OnboardingRouterSpy())

        // Then
        #expect(viewModel.step == .welcome)
        #expect(viewModel.birthday == .mock(year: 2000, month: 1, day: 1, hour: 0))
    }
}
