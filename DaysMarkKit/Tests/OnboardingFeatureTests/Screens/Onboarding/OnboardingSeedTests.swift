//
//  OnboardingSeedTests.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import OnboardingFeature

struct OnboardingSeedTests {
    @Test(arguments: [
        (OnboardingSeed.newYear, "onboarding.seed.newYear"),
        (.fallbackNewYear, "onboarding.seed.newYear"),
        (.nextMonth, "onboarding.seed.nextMonth"),
        (.monthEnd, "onboarding.seed.endOfMonth"),
        (.birthday, "onboarding.seed.birthday"),
        (.birthDate, "onboarding.seed.birthDate"),
        (.fallbackYearProgress, "onboarding.seed.yearProgress"),
    ])
    func titleThenNamesTheReadyMadeEvent(seed: OnboardingSeed, key: String) {
        #expect(seed.title.key == key)
    }

    @Test(arguments: OnboardingSeed.allCases)
    func noteThenExistsOnlyForTheBirthdayWithReminders(seed: OnboardingSeed) {
        #expect((seed.note != nil) == (seed == .birthday))
    }
}
