//
//  OnboardingRouter.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Observation
import SunUserInterface

@Observable
final class OnboardingRouter: FeatureRouting, OnboardingRouting {
    private let onComplete: () -> Void

    var presentation: FeaturePresentation<OnboardingDestination>?
    var path: [OnboardingDestination] = []

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    func view(for destination: OnboardingDestination) -> OnboardingDestinationView {
        OnboardingDestinationView(destination: destination)
    }

    func finishOnboarding() {
        onComplete()
    }
}
