//
//  OnboardingSeedPlan.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/10/07.
//

import Foundation

public struct OnboardingSeedPlan {
    private let calendar: Calendar
    private let now: Date

    public init(calendar: Calendar, now: Date) {
        self.calendar = calendar
        self.now = now
    }

    public func event(
        for seed: OnboardingSeed,
        birthday: BirthdayCandidate?
    ) throws(OnboardingError) -> CountdownEvent {
        try eventSeed(for: seed, birthday: birthday).event(createdAt: now)
    }

    func eventSeed(
        for seed: OnboardingSeed,
        birthday: BirthdayCandidate?
    ) throws(OnboardingError) -> EventSeed {
        EventSeed(
            id: seed.eventID,
            identifier: seed.rawValue,
            title: title(for: seed),
            date: try date(for: seed, birthday: birthday),
            timeZone: calendar.timeZone,
            repeatRule: repeatRule(for: seed),
            category: category(for: seed),
            reminders: reminders(for: seed)
        )
    }

    private var dayUnits: Set<Calendar.Component> { [.era, .year, .month, .day] }

    private func date(
        for seed: OnboardingSeed,
        birthday: BirthdayCandidate?
    ) throws(OnboardingError) -> EventDateSpecification {
        let calendarSystem = calendarSystem(for: seed)
        var calendar = Calendar(identifier: calendarSystem.identifier)
        calendar.timeZone = self.calendar.timeZone

        let components: DateComponents? =
            switch seed {
            case .birthday, .birthDate:
                try birthdayComponents(of: birthday, in: calendar)
            case .newYear, .fallbackNewYear:
                nextNewYear
            case .nextMonth:
                calendar.dateInterval(of: .month, for: now)
                    .flatMap { calendar.date(byAdding: .month, value: 1, to: $0.start) }
                    .map { calendar.dateComponents(dayUnits, from: $0) }
            case .monthEnd:
                calendar.dateInterval(of: .month, for: now)
                    .flatMap { calendar.date(byAdding: .day, value: -1, to: $0.end) }
                    .map { calendar.dateComponents(dayUnits, from: $0) }
            case .fallbackYearProgress:
                calendar.dateInterval(of: .year, for: now)
                    .map { calendar.dateComponents(dayUnits, from: $0.start) }
            }

        guard let components,
            let year = components.year,
            let month = components.month,
            let day = components.day
        else { throw .dateUnavailable }

        return EventDateSpecification(
            calendarSystem: calendarSystem,
            era: components.era,
            year: year,
            month: month,
            day: day,
            isLeapMonth: components.isLeapMonth ?? false
        )
    }

    private var nextNewYear: DateComponents {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone

        return DateComponents(year: gregorian.component(.year, from: now) + 1, month: 1, day: 1)
    }

    private func birthdayComponents(
        of birthday: BirthdayCandidate?,
        in calendar: Calendar
    ) throws(OnboardingError) -> DateComponents {
        guard let birthday else { throw .invalidBirthday }

        return calendar.dateComponents(dayUnits, from: birthday.date)
    }

    private func calendarSystem(for seed: OnboardingSeed) -> EventCalendarSystem {
        switch seed {
        case .newYear, .fallbackNewYear: .gregorian
        default: EventCalendarSystem(supporting: calendar.identifier)
        }
    }

    private func repeatRule(for seed: OnboardingSeed) -> RepeatRule {
        switch seed {
        case .newYear, .fallbackNewYear, .birthday: .yearly
        case .nextMonth: .monthly
        case .monthEnd: .monthlyLastDay
        case .fallbackYearProgress: .currentYearStart
        case .birthDate: .never
        }
    }

    private func category(for seed: OnboardingSeed) -> BuiltInCategory {
        switch seed {
        case .birthday, .birthDate: .birthday
        default: .important
        }
    }

    private func reminders(for seed: OnboardingSeed) -> [ReminderDraft] {
        switch seed {
        case .birthday: [7, 1, 0].map { ReminderDraft(daysBefore: $0, hour: 9, minute: 0) }
        default: []
        }
    }

    private func title(for seed: OnboardingSeed) -> String {
        switch seed {
        case .newYear, .fallbackNewYear:
            String(localized: "onboarding.seed.newYear", bundle: .module)
        case .nextMonth: String(localized: "onboarding.seed.nextMonth", bundle: .module)
        case .monthEnd: String(localized: "onboarding.seed.endOfMonth", bundle: .module)
        case .birthday: String(localized: "onboarding.seed.birthday", bundle: .module)
        case .birthDate: String(localized: "onboarding.seed.birthDate", bundle: .module)
        case .fallbackYearProgress:
            String(localized: "onboarding.seed.yearProgress", bundle: .module)
        }
    }
}
