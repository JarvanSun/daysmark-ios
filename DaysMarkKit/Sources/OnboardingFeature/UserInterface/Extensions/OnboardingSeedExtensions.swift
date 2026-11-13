//
//  OnboardingSeedExtensions.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

extension OnboardingSeed {
    var title: LocalizedStringResource {
        switch self {
        case .newYear, .fallbackNewYear:
            LocalizedStringResource("onboarding.seed.newYear", bundle: .module)
        case .nextMonth: LocalizedStringResource("onboarding.seed.nextMonth", bundle: .module)
        case .monthEnd: LocalizedStringResource("onboarding.seed.endOfMonth", bundle: .module)
        case .birthday: LocalizedStringResource("onboarding.seed.birthday", bundle: .module)
        case .birthDate: LocalizedStringResource("onboarding.seed.birthDate", bundle: .module)
        case .fallbackYearProgress:
            LocalizedStringResource("onboarding.seed.yearProgress", bundle: .module)
        }
    }

    var note: LocalizedStringResource? {
        switch self {
        case .birthday:
            LocalizedStringResource("onboarding.seed.birthday.reminders", bundle: .module)
        case .newYear, .nextMonth, .monthEnd, .birthDate, .fallbackYearProgress, .fallbackNewYear:
            nil
        }
    }
}
