//
//  OnboardingDependencies.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

public struct OnboardingDependencies {
    let onComplete: () -> Void

    let completer: OnboardingCompleting
    let calendar: Calendar
    let now: () -> Date

    public init(
        completer: OnboardingCompleting,
        calendar: Calendar,
        now: @escaping () -> Date,
        onComplete: @escaping () -> Void
    ) {
        self.completer = completer
        self.calendar = calendar
        self.now = now
        self.onComplete = onComplete
    }

    func makeViewModel(router: OnboardingRouting) -> OnboardingViewModel {
        OnboardingViewModel(
            birthday: firstDayOf2000(),
            calendar: calendar,
            now: now,
            completer: completer,
            router: router
        )
    }

    private func firstDayOf2000() -> Date {
        let components = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: calendar.timeZone,
            year: 2000,
            month: 1,
            day: 1
        )

        return components.date ?? now()
    }
}
