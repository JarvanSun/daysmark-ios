//
//  OnboardingIssue.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation

enum OnboardingIssue {
    case invalidBirthday
    case unknown

    init(_ error: OnboardingError) {
        switch error {
        case .invalidBirthday: self = .invalidBirthday
        case .dateUnavailable, .storeFailure: self = .unknown
        }
    }
}

extension OnboardingIssue: IssuePresenting {
    var title: LocalizedStringResource {
        LocalizedStringResource("onboarding.issue.title", bundle: .module)
    }

    var message: LocalizedStringResource? {
        switch self {
        case .invalidBirthday:
            LocalizedStringResource("onboarding.issue.birthdayNotSaved", bundle: .module)
        case .unknown: nil
        }
    }
}
