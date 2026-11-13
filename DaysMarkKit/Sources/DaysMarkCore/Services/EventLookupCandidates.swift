//
//  EventLookupCandidates.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension EventLookup {
    public func candidate(creating input: EventCreationInput) throws(EventLookupError)
        -> EventCandidate
    {
        var draft = EventDraft(
            startingOn: input.startDate,
            categoryID: input.categoryID ?? BuiltInCategory.important.id,
            timeZone: timeZone()
        )
        draft.title = input.title
        draft.endDate = input.endDate
        draft.timeSemantics = timeSemantics(includingTime: input.includesTime)
        draft.repeatRule = input.repeatRule

        if let days = input.reminderDaysBefore {
            draft.reminders = [try reminder(daysBefore: days, includingTime: input.includesTime)]
        }

        return try candidate(for: draft, replacing: nil)
    }

    public func candidate(
        editing eventID: CountdownEvent.ID,
        with input: EventEditInput
    ) throws(EventLookupError) -> EventCandidate {
        guard let event = activeEvents().first(where: { $0.id == eventID }) else {
            throw .eventNotFound
        }

        var draft = EventDraft(event, at: now(), in: timeZone())

        if let title = input.title {
            draft.title = title
        }

        if let startDate = input.startDate {
            draft.targetDate = startDate
            draft.endDate = nil
        }

        if let includesTime = input.includesTime {
            draft.timeSemantics = timeSemantics(includingTime: includesTime)
            draft.timeSemanticsChanged()
        }

        if let categoryID = input.categoryID {
            draft.categoryID = categoryID
        }

        return try candidate(for: draft, replacing: eventID)
    }
}

// MARK: - Private

private extension EventLookup {
    var allDayReminderHour: Int { 9 }

    var minutesPerDay: Int { 1_440 }

    func timeSemantics(includingTime includesTime: Bool) -> EventTimeSemantics {
        includesTime ? .floatingLocalTime : .floatingAllDay
    }

    func reminder(daysBefore days: Int, includingTime includesTime: Bool)
        throws(EventLookupError) -> ReminderDraft
    {
        guard days >= 0 else { throw .reminderNotAllowed }

        return switch includesTime {
        case true: ReminderDraft(kind: .exactTimeOffset, minutesBefore: days * minutesPerDay)
        case false: ReminderDraft(daysBefore: days, hour: allDayReminderHour, minute: 0)
        }
    }

    func candidate(for draft: EventDraft, replacing eventID: CountdownEvent.ID?)
        throws(EventLookupError) -> EventCandidate
    {
        guard draft.isValid else { throw .invalidDraft }

        return EventCandidate(
            eventID: eventID,
            draft: draft,
            confirmation: confirmation(for: draft)
        )
    }

    func confirmation(for draft: EventDraft) -> String {
        let title = draft.trimmedTitle
        let dateStyle = Date.FormatStyle(
            date: .long,
            time: draft.timeSemantics == .floatingAllDay ? .omitted : .shortened,
            locale: locale(),
            calendar: locale().calendar,
            timeZone: timeZone()
        )
        let date = draft.targetDate.formatted(dateStyle)
        let category = categoryName(for: draft.categoryID)

        return String(
            localized: "lookup.confirmation \(title) \(date) \(category)",
            bundle: .module
        )
    }
}

// MARK: - Inputs and candidate

public struct EventCreationInput: Equatable, Sendable {
    public var title: String
    public var startDate: Date
    public var includesTime = false
    public var endDate: Date?
    public var categoryID: EventCategory.ID?
    public var repeatRule: RepeatRule = .never
    public var reminderDaysBefore: Int?

    public init(title: String, startDate: Date) {
        self.title = title
        self.startDate = startDate
    }
}

public struct EventEditInput: Equatable, Sendable {
    let title: String?
    let startDate: Date?
    let includesTime: Bool?
    let categoryID: EventCategory.ID?

    public init(title: String?, startDate: Date?, includesTime: Bool?, categoryID: UUID?) {
        self.title = title
        self.startDate = startDate
        self.includesTime = includesTime
        self.categoryID = categoryID
    }
}

public struct EventCandidate: Equatable, Sendable {
    public let eventID: CountdownEvent.ID?
    public let draft: EventDraft
    public let confirmation: String
}
