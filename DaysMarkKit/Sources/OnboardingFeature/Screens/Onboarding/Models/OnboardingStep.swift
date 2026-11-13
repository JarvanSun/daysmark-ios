//
//  OnboardingStep.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/09/04.
//

import Foundation

enum OnboardingStep {
    case welcome
    case birthday
    case quickEvents
}

extension OnboardingStep {
    var title: LocalizedStringResource {
        switch self {
        case .welcome: LocalizedStringResource("onboarding.welcome.title", bundle: .module)
        case .birthday: LocalizedStringResource("onboarding.birthday.title", bundle: .module)
        case .quickEvents: LocalizedStringResource("onboarding.seeds.title", bundle: .module)
        }
    }

    var subtitle: LocalizedStringResource {
        switch self {
        case .welcome: LocalizedStringResource("onboarding.welcome.message", bundle: .module)
        case .birthday: LocalizedStringResource("onboarding.birthday.message", bundle: .module)
        case .quickEvents: LocalizedStringResource("onboarding.seeds.message", bundle: .module)
        }
    }
}
