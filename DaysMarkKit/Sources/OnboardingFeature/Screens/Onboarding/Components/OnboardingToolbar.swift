//
//  OnboardingToolbar.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct OnboardingToolbar: ToolbarContent {
    let viewModel: OnboardingViewModel

    var body: some ToolbarContent {
        switch viewModel.step {
        case .welcome: skipItem
        case .birthday: birthdayItems
        case .quickEvents: backItem
        }
    }

    private var skipItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                viewModel.startWithBasics()
            } label: {
                Text("onboarding.toolbar.skip", bundle: .module)
            }
            .disabled(viewModel.isSaving)
        }
    }

    @ToolbarContentBuilder
    private var birthdayItems: some ToolbarContent {
        backItem

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.skipBirthday()
            } label: {
                Text("onboarding.toolbar.skipBirthday.title", bundle: .module)
            }
            .accessibilityLabel(
                Text("onboarding.toolbar.skipBirthday.accessibilityLabel", bundle: .module)
            )
        }
    }

    private var backItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.goBack()
            } label: {
                Label(Text("onboarding.toolbar.back", bundle: .module), symbol: .chevronBackward)
            }
            .disabled(viewModel.isSaving)
        }
    }
}
