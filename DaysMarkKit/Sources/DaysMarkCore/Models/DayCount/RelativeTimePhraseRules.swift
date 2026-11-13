//
//  RelativeTimePhraseRules.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation

struct RelativeTimePhraseRules {
    let now: Date
    let userTimeZone: TimeZone
    let locale: Locale

    func phrase(for subject: RelativeTimeSubject) -> RelativeTimePhrase {
        momentPhrase(for: subject).placed(in: rangePhase(of: subject))
    }

    private func momentPhrase(for subject: RelativeTimeSubject) -> RelativeTimePhrase {
        guard subject.timeSemantics != .floatingAllDay, let target = subject.date else {
            return RelativeTimePhrase(subject.dayCount)
        }

        var calendar = Calendar(identifier: subject.calendarSystem.identifier)
        calendar.timeZone =
            switch subject.timeSemantics {
            case .fixedInstant: subject.timeZone ?? userTimeZone
            case .floatingAllDay, .floatingLocalTime: userTimeZone
            }

        guard calendar.isDate(now, inSameDayAs: target) else {
            return RelativeTimePhrase(subject.dayCount)
        }

        return RelativeTimePhrase(target: target, now: now, locale: locale)
    }

    private func rangePhase(of subject: RelativeTimeSubject) -> RelativeTimePhrase.Phase {
        guard let start = subject.rangeStart, let end = subject.rangeEnd else { return .point }

        var calendar = Calendar(identifier: subject.calendarSystem.identifier)
        calendar.timeZone = userTimeZone

        let (moment, first, last) =
            switch subject.timeSemantics {
            case .floatingAllDay:
                (
                    calendar.startOfDay(for: now),
                    calendar.startOfDay(for: start),
                    calendar.startOfDay(for: end)
                )
            case .fixedInstant, .floatingLocalTime:
                (now, start, end)
            }

        return switch (moment < first, moment <= last) {
        case (true, _): .beforeStart
        case (false, true): .ongoing
        case (false, false): .ended
        }
    }
}

struct RelativeTimeSubject {
    let dayCount: DayCount
    let timeSemantics: EventTimeSemantics
    let calendarSystem: EventCalendarSystem
    let timeZone: TimeZone?
    let date: Date?
    let rangeStart: Date?
    let rangeEnd: Date?
}
