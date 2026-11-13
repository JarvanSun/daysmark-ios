//
//  OnboardingPrimaryAction.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

enum OnboardingPrimaryAction {
    case next
    case createSelected
    case startWithBasics
}

extension OnboardingPrimaryAction {
    var title: LocalizedStringResource {
        switch self {
        case .next: LocalizedStringResource("onboarding.action.continue", bundle: .module)
        case .createSelected:
            LocalizedStringResource("onboarding.action.createSelected", bundle: .module)
        case .startWithBasics:
            LocalizedStringResource("onboarding.action.startWithBasics", bundle: .module)
        }
    }
}
