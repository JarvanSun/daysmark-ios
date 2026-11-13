//
//  OnboardingCompleterSpy.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

final class OnboardingCompleterSpy: OnboardingCompleting {
    private(set) var completions: [Completion] = []

    private let error: OnboardingError?

    init(error: OnboardingError? = nil) {
        self.error = error
    }

    func complete(
        birthday: BirthdayCandidate?,
        selected: Set<OnboardingSeed>
    ) async throws(OnboardingError) {
        completions.append(Completion(birthday: birthday, seeds: selected))

        if let error {
            throw error
        }
    }
}

extension OnboardingCompleterSpy {
    struct Completion: Equatable {
        let birthday: BirthdayCandidate?
        let seeds: Set<OnboardingSeed>
    }
}
