//
//  OnboardingIssueTests.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import OnboardingFeature

struct OnboardingIssueTests {
    @Test func initWhenBirthdayIsInvalidThenNamesTheBirthday() {
        // Given / When
        let issue = OnboardingIssue(.invalidBirthday)

        // Then
        #expect(issue == .invalidBirthday)
    }

    @Test(arguments: [OnboardingError.dateUnavailable, .storeFailure])
    func initWhenSeedingFailsThenIsUnknown(error: OnboardingError) {
        // Given / When
        let issue = OnboardingIssue(error)

        // Then
        #expect(issue == .unknown)
    }

    @Test(arguments: [OnboardingIssue.invalidBirthday, .unknown])
    func titleThenSaysSavingFailed(issue: OnboardingIssue) {
        #expect(issue.title.key == "onboarding.issue.title")
    }

    @Test(arguments: [
        (OnboardingIssue.invalidBirthday, "onboarding.issue.birthdayNotSaved" as String?),
        (.unknown, nil),
    ])
    func messageThenExplainsOnlyAKnownIssue(issue: OnboardingIssue, key: String?) {
        #expect(issue.message?.key == key)
    }
}
