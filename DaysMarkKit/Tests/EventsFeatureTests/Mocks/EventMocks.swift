//
//  EventMocks.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import Foundation

@testable import DaysMarkCore
@testable import EventsFeature

extension CountdownEvent {
    static func mock(
        _ title: String = "Trip",
        id: UUID = UUID(),
        year: Int = 2030,
        month: Int = 9,
        day: Int = 15,
        timeZone: TimeZone = .gmt,
        category: EventCategory? = nil
    ) -> CountdownEvent {
        .init(
            id: id,
            title: title,
            year: year,
            month: month,
            day: day,
            timeZone: timeZone,
            category: category,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func mockTimed(
        _ title: String = "Call",
        hour: Int,
        minute: Int,
        timeZone: TimeZone = .gmt,
        semantics: EventTimeSemantics
    ) -> CountdownEvent {
        .init(
            title: title,
            year: 2030,
            month: 9,
            day: 10,
            hour: hour,
            minute: minute,
            timeZone: timeZone,
            repeatRule: .yearly,
            timeSemantics: semantics,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func mockDeleted(id: UUID = UUID()) -> CountdownEvent {
        let event = CountdownEvent.mock("Deleted", id: id)
        event.deletedAt = .mockNow

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
        .init(
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
    }
}

extension EventDraft {
    static func mock(
        _ title: String = "Trip",
        on date: Date = .mockNow,
        repeating repeatRule: RepeatRule = .never
    ) -> EventDraft {
        var draft = EventDraft(
            startingOn: date,
            categoryID: BuiltInCategory.important.id,
            timeZone: .gmt
        )
        draft.title = title
        draft.repeatRule = repeatRule

        return draft
    }
}

extension FocusSelection {
    static func mock(selecting eventID: UUID?) -> FocusSelection {
        .init(id: UUID(), eventID: eventID, updatedAt: .mockNow)
    }
}

extension EventItem {
    static func mock(_ event: CountdownEvent, at time: CurrentTime = .mock()) -> EventItem {
        let item = EventSorter()
            .counted([event], now: time.now, userTimeZone: time.timeZone)
            .first!

        return .init(item, at: time)
    }
}
