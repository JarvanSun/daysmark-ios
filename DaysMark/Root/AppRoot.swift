//
//  AppRoot.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/07/25.
//

import DaysMarkCore
import DesignSystem
import EventsFeature
import OnboardingFeature
import SwiftUI

struct AppRoot: View {
    @Bindable var viewModel: AppRootViewModel

    let dependencies: AppDependencies
    let notificationRequests: AppRequestInbox

    var body: some View {
        screen
            .task { await viewModel.observeStore() }
            .onChange(of: notificationRequests.pendingRequest, initial: true) {
                viewModel.open(notificationRequests.takePendingRequest())
            }
            .onChange(of: dependencies.intentRequests.pendingRequest, initial: true) {
                viewModel.open(dependencies.intentRequests.takePendingRequest())
            }
    }

    @ViewBuilder
    private var screen: some View {
        switch viewModel.showsOnboarding {
        case true: onboarding
        case false: events
        }
    }

    private var onboarding: some View {
        OnboardingHostView(
            dependencies: dependencies.onboarding(onComplete: { finishOnboarding() })
        )
        .transition(.opacity)
    }

    private func finishOnboarding() {
        withAnimation(DaysMarkMotion.onboardingFinish.animation) {
            viewModel.finishOnboarding()
        }
    }

    private var events: some View {
        EventsHostView(
            dependencies: dependencies.events(),
            request: $viewModel.pendingRequest
        )
        .transition(.opacity)
        .onOpenURL { viewModel.open($0) }
        .focusedSceneValue(\.appRequest, $viewModel.pendingRequest)
    }
}
