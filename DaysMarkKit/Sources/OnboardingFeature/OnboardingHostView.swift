//
//  OnboardingHostView.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public struct OnboardingHostView: View {
    private let dependencies: OnboardingDependencies

    public init(dependencies: OnboardingDependencies) {
        self.dependencies = dependencies
    }

    public var body: some View {
        OnboardingNavigationHost(dependencies: dependencies)
    }
}

#if DEBUG
#Preview("Onboarding") {
    OnboardingHostView(dependencies: PreviewObjectPool().onboardingDependencies())
}
#endif
