//
//  EventRepetition.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct EventRepetition {
    let event: CountdownEvent
    let start: EventDateSpecification
    let startDate: Date
    let calendar: Calendar
    let zones: EventTimeZones

    func estimatedPeriods(until now: Date) -> Int {
        guard now > startDate, let period else { return 0 }

        let elapsed =
            calendar.dateComponents([period.component], from: startDate, to: now)
            .value(for: period.component) ?? 0

        return max(0, elapsed / period.length)
    }

    func start(afterPeriods step: Int) -> EventDateSpecification? {
        guard step > 0, let period else { return start }

        switch event.repeatRule {
        case .monthlyLastDay: return lastDayOfMonth(afterMonths: step)
        default: return shiftedStart(by: period.length * step, period.component)
        }
    }

    private var period: Period? {
        let interval = event.repeatRule.clampedInterval(event.repeatInterval)

        return switch (event.repeatRule, event.repeatUnit) {
        case (.never, _), (.currentYearStart, _): nil
        case (.yearly, _): Period(component: .year, length: 1)
        case (.monthly, _), (.monthlyLastDay, _): Period(component: .month, length: 1)
        case (.custom, .day): Period(component: .day, length: interval)
        case (.custom, .week): Period(component: .day, length: interval * 7)
        case (.custom, .month): Period(component: .month, length: interval)
        case (.custom, .year): Period(component: .year, length: interval)
        }
    }

    private func lastDayOfMonth(afterMonths step: Int) -> EventDateSpecification? {
        guard
            let first = calendar.date(
                from: DateComponents(year: start.year, month: start.month, day: 1)
            ), let shifted = calendar.date(byAdding: .month, value: step, to: first),
            let range = calendar.range(of: .day, in: .month, for: shifted)
        else { return nil }

        let shiftedComponents = calendar.dateComponents([.era, .year, .month], from: shifted)
        var result = start
        result.era = shiftedComponents.era
        result.year = shiftedComponents.year ?? start.year
        result.month = shiftedComponents.month ?? start.month
        result.day = range.count

        return result
    }

    private func shiftedStart(by value: Int, _ component: Calendar.Component)
        -> EventDateSpecification?
    {
        guard let shifted = calendar.date(byAdding: component, value: value, to: startDate),
            var result = start.moved(
                to: shifted,
                semantics: event.timeSemantics,
                timeZone: calendar.timeZone
            ),
            fallsOnTheSameDay(result, shiftedBy: component)
        else { return nil }

        if event.timeSemantics == .fixedInstant {
            guard let eventTimeZone = zones.event,
                let offset = result.firstMatchingUTCOffset(in: eventTimeZone)
            else { return nil }

            result.utcOffsetSecondsAtCreation = offset
        }

        let resolved = result.resolvedDate(
            semantics: event.timeSemantics,
            eventTimeZone: zones.event,
            userTimeZone: zones.user
        )

        guard resolved != nil else { return nil }

        return result
    }

    private func fallsOnTheSameDay(
        _ result: EventDateSpecification,
        shiftedBy component: Calendar.Component
    ) -> Bool {
        switch component {
        case .year:
            result.month == start.month
                && result.day == start.day
                && result.isLeapMonth == start.isLeapMonth
        case .month: result.day == start.day
        default: true
        }
    }
}

extension EventRepetition {
    private struct Period {
        let component: Calendar.Component
        let length: Int
    }
}
