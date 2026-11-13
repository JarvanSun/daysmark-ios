//
//  OnboardingNavigationHost.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI

struct OnboardingNavigationHost: FeatureHost {
    @State private var router: OnboardingRouter
    @State private var viewModel: OnboardingViewModel

    var featureRouter: OnboardingRouter { router }

    var root: some View {
        OnboardingView(viewModel: viewModel)
    }

    init(dependencies: OnboardingDependencies) {
        let router = OnboardingRouter(onComplete: dependencies.onComplete)
        _router = State(initialValue: router)
        _viewModel = State(initialValue: dependencies.makeViewModel(router: router))
    }
}
