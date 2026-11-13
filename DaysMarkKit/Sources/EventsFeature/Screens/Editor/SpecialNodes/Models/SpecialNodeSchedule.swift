//
//  SpecialNodeSchedule.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

struct SpecialNodeSchedule {
    let draft: EventDraft
    let now: Date
    let userTimeZone: TimeZone

    func availability(of preset: SpecialNodePreset) -> SpecialNodeAvailability {
        guard preset.value > 0, let event = draft.previewEvent(at: now) else { return .invalidDate }
        guard let start = startDate(of: event) else { return .invalidDate }
        guard let day = day(of: preset, for: event, startingOn: start) else { return .invalidDate }
        guard let minuteOfDay = draft.specialNodeNotificationMinuteOfDay else { return .available }

        let notification = notificationDate(on: day, minuteOfDay: minuteOfDay, for: event)

        return switch (notification, event.repeatRule) {
        case (nil, _): .invalidDate
        case (.some(let date), _) where date > now: .available
        case (.some, .never): .targetInPast
        case (.some, _): availabilityOfLaterOccurrence(of: event, for: preset)
        }
    }

    private var zone: TimeZone {
        draft.timeSemantics == .fixedInstant ? draft.timeZone : userTimeZone
    }

    private func calendar(for event: CountdownEvent) -> Calendar {
        var calendar = Calendar(identifier: event.calendarSystem.identifier)
        calendar.timeZone = zone

        return calendar
    }

    private func startDate(of event: CountdownEvent) -> Date? {
        event.startDateSpecification.resolvedDate(
            semantics: event.timeSemantics,
            eventTimeZone: event.timeSemantics == .fixedInstant ? event.timeZone : nil,
            userTimeZone: zone
        )
    }

    private func nextOccurrenceStart(of event: CountdownEvent) -> Date? {
        EventOccurrenceResolver().nextOccurrence(for: event, now: now, userTimeZone: zone)?
            .startDate
    }

    private func day(
        of preset: SpecialNodePreset,
        for event: CountdownEvent,
        startingOn start: Date
    ) -> Date? {
        let calendar = calendar(for: event)
        let anchor = anchor(of: event, startingOn: start)

        return switch preset.kind {
        case .beforeDays: calendar.date(byAdding: .day, value: -preset.value, to: anchor)
        case .elapsedDays: calendar.date(byAdding: .day, value: preset.value, to: start)
        case .anniversaryYears: anniversary(preset.value, after: start, in: calendar)
        }
    }

    private func anchor(of event: CountdownEvent, startingOn start: Date) -> Date {
        switch event.repeatRule {
        case .never: start
        default: nextOccurrenceStart(of: event) ?? start
        }
    }

    private func anniversary(_ years: Int, after start: Date, in calendar: Calendar) -> Date? {
        guard let shifted = calendar.date(byAdding: .year, value: years, to: start) else {
            return nil
        }

        let components: Set<Calendar.Component> = [.era, .year, .month, .day]
        let original = calendar.dateComponents(components, from: start)
        let moved = calendar.dateComponents(components, from: shifted)
        let fallsOnTheSameDay =
            moved.era == original.era
            && moved.month == original.month
            && moved.day == original.day
            && moved.isLeapMonth == original.isLeapMonth

        return fallsOnTheSameDay ? shifted : nil
    }

    private func notificationDate(on day: Date, minuteOfDay: Int, for event: CountdownEvent)
        -> Date?
    {
        let calendar = calendar(for: event)
        var components = calendar.dateComponents([.era, .year, .month, .day], from: day)
        components.hour = minuteOfDay / 60
        components.minute = minuteOfDay % 60

        return calendar.strictDate(from: components)
    }

    private func availabilityOfLaterOccurrence(
        of event: CountdownEvent,
        for preset: SpecialNodePreset
    ) -> SpecialNodeAvailability {
        switch (preset.kind, nextOccurrenceStart(of: event)) {
        case (.beforeDays, .some): .available
        default: .noFutureOccurrence
        }
    }
}
