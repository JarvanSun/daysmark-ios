//
//  EventMocks.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

@testable import DaysMarkCore

// MARK: - CountdownEvent

extension CountdownEvent {
    static func mock(
        title: String = "Trip",
        reminderDays: [Int] = [],
        category: EventCategory? = nil
    ) -> CountdownEvent {
        let event = CountdownEvent(
            title: title,
            year: 2030,
            month: 9,
            day: 10,
            timeZone: .mockUTC,
            category: category,
            createdAt: .mockNow,
            updatedAt: .mockNow
        )
        event.reminders = reminderDays.map {
            let rule = ReminderRule(eventID: event.id, daysBefore: $0, hour: 9)
            rule.event = event
            return rule
        }

        return event
    }

    static func mock(
        id: UUID = UUID(),
        recordID: UUID = UUID(),
        title: String,
        year: Int,
        month: Int,
        day: Int,
        hour: Int? = nil,
        minute: Int? = nil,
        timeZone: TimeZone = .current,
        endYear: Int? = nil,
        endMonth: Int? = nil,
        endDay: Int? = nil,
        countsFromDayOne: Bool = false,
        icon: String = "",
        repeatRule: RepeatRule = .never,
        repeatInterval: Int = 1,
        repeatUnit: RepeatUnit = .year,
        category: EventCategory? = nil,
        seedIdentifier: String? = nil,
        calendarSystem: EventCalendarSystem = .gregorian,
        timeSemantics: EventTimeSemantics? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) -> CountdownEvent {
        let event = CountdownEvent(
            id: id,
            recordID: recordID,
            title: title,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            timeZone: timeZone,
            endYear: endYear,
            endMonth: endMonth,
            endDay: endDay,
            countsFromDayOne: countsFromDayOne,
            icon: icon,
            repeatRule: repeatRule,
            repeatInterval: repeatInterval,
            repeatUnit: repeatUnit,
            category: category,
            seedIdentifier: seedIdentifier,
            calendarSystem: calendarSystem,
            timeSemantics: timeSemantics,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        return event
    }
}

// MARK: - EventDraft

extension EventDraft {
    static var mock: EventDraft {
        EventDraft(
            startingOn: .mockNow,
            categoryID: BuiltInCategory.important.id,
            timeZone: .mockUTC
        )
    }

    static func mock(_ title: String, on date: Date = .mockNow) -> EventDraft {
        var draft = EventDraft.mock
        draft.title = title
        draft.targetDate = date

        return draft
    }

    static func mock(of event: CountdownEvent) -> EventDraft {
        EventDraft(event, at: .mockNow, in: .mockUTC)
    }
}

// MARK: - EventSeed

extension EventSeed {
    static var mockNewYear: EventSeed {
        .mock()
    }

    static func mock(
        id: UUID = .mockSeedID,
        identifier: String = "onboarding.new-year.v1",
        category: BuiltInCategory = .important,
        reminders: [ReminderDraft] = []
    ) -> EventSeed {
        EventSeed(
            id: id,
            identifier: identifier,
            title: "New Year",
            date: EventDateSpecification(calendarSystem: .gregorian, year: 2027, month: 1, day: 1),
            timeZone: .mockUTC,
            repeatRule: .yearly,
            category: category,
            reminders: reminders
        )
    }
}

// MARK: - FocusSelection

extension FocusSelection {
    static func mock(
        recordID: UUID = UUID(),
        eventID: UUID?,
        currentRevisionID: UUID? = nil,
        updatedAt: Date = .mockNow
    ) -> FocusSelection {
        FocusSelection(
            id: .mockFocusSelectionID,
            recordID: recordID,
            eventID: eventID,
            currentRevisionID: currentRevisionID,
            updatedAt: updatedAt
        )
    }
}

// MARK: - EventCreationInput

extension EventCreationInput {
    static var mockTrip: EventCreationInput {
        EventCreationInput(title: "Trip", startDate: .mock(2030, 9, 10))
    }
}

// MARK: - ImportedDate

extension ImportedDate {
    static var mockContactBirthday: ImportedDate {
        .mock()
    }

    static var mockTimedCalendarEvent: ImportedDate {
        .mock(
            sourceKind: .calendar,
            sourceIdentifier: "calendar-event",
            title: "Launch",
            date: .mock(2031, 5, 4, hour: 9, in: .mockTokyo).addingTimeInterval(30 * 60),
            repeatsYearly: false,
            timeZone: .mockTokyo,
            includesTime: true
        )
    }

    static func mock(
        sourceKind: ImportSourceKind = .contacts,
        sourceIdentifier: String = "private-contact-id",
        title: String = "Mary’s Birthday",
        date: Date = .mock(2000, 4, 8, hour: 0),
        repeatsYearly: Bool = true,
        calendarSystem: EventCalendarSystem = .gregorian,
        timeZone: TimeZone = .mockUTC,
        includesTime: Bool = false
    ) -> ImportedDate {
        ImportedDate(
            sourceKind: sourceKind,
            sourceIdentifier: sourceIdentifier,
            title: title,
            date: date,
            repeatsYearly: repeatsYearly,
            calendarSystem: calendarSystem,
            timeZone: timeZone,
            includesTime: includesTime
        )
    }
}

// MARK: - ImportedEventContent

extension ImportedEventContent {
    static var mockContactBirthday: ImportedEventContent {
        .mock()
    }

    static func mock(
        title: String = "  Mary’s Birthday ",
        day: Int = 8,
        snapshotDigest: String = "imported-snapshot"
    ) -> ImportedEventContent {
        ImportedEventContent(
            title: title,
            date: EventDateSpecification(
                calendarSystem: .gregorian,
                era: 1,
                year: 2000,
                month: 4,
                day: day
            ),
            timeZone: .mockUTC,
            repeatRule: .yearly,
            timeSemantics: .floatingAllDay,
            sourceKind: .contacts,
            snapshotDigest: snapshotDigest
        )
    }
}
