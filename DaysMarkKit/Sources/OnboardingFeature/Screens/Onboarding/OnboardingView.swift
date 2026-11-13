//
//  OnboardingView.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/09/03.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct OnboardingView: View {
    @Environment(\.dimensions) private var dimensions

    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        PageScrollView(topPadding: dimensions.spaceXLarge) {
            VStack(alignment: .leading, spacing: dimensions.spaceLargeSmall) {
                OnboardingHeader(step: viewModel.step)

                VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
                    if let headline = viewModel.content.headline {
                        CountdownSentence(
                            sentence: headline,
                            titleFont: .heroTitle,
                            phraseFont: .heroPhrase
                        )
                    }

                    if let detail = viewModel.content.detail {
                        CountdownSentence(
                            sentence: detail,
                            titleFont: .rowTitle,
                            phraseFont: .rowPhrase
                        )
                    }
                }

                LandscapeIllustration(
                    markers: viewModel.content.horizon.compactMap(\.landscapeMarker)
                )

                stepContent
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaBar(edge: .bottom) {
            OnboardingActionBar(
                action: viewModel.content.primaryAction,
                isSaving: viewModel.isSaving,
                onPerform: { viewModel.performPrimaryAction() }
            )
        }
        .overlay {
            if viewModel.content.celebratesBirthday {
                ConfettiView()
            }
        }
        .toolbar { OnboardingToolbar(viewModel: viewModel) }
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        .sensoryFeedback(.selection, trigger: viewModel.selection)
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.step)
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() }) { _ in
            Button {
                viewModel.createSelectedDates()
            } label: {
                Text("onboarding.issue.retry", bundle: .module)
            }

            Button {
                viewModel.startWithBasics()
            } label: {
                Text("onboarding.issue.startWithBasics", bundle: .module)
            }
        }
        .task(id: viewModel.saveRequest) { await viewModel.save() }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .welcome: EmptyView()
        case .birthday:
            DatePicker(selection: $viewModel.birthday, displayedComponents: .date) {
                Text("onboarding.birthday.picker", bundle: .module)
            }
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
        case .quickEvents:
            VStack(spacing: 0) {
                ForEach(viewModel.content.candidates) { candidate in
                    OnboardingCandidateRow(candidate: candidate) {
                        viewModel.toggle(candidate.seed)
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview("Onboarding", arguments: OnboardingPreviewState.allCases) { state in
    NavigationStack {
        OnboardingView(viewModel: PreviewObjectPool().onboardingViewModel(state))
    }
    .environment(\.locale, state.locale)
}
#endif
