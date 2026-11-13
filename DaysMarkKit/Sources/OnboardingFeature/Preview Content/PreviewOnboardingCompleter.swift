//
//  PreviewOnboardingCompleter.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore

struct PreviewOnboardingCompleter: OnboardingCompleting {
    func complete(
        birthday: BirthdayCandidate?,
        selected: Set<OnboardingSeed>
    ) async throws(OnboardingError) {}
}
#endif
