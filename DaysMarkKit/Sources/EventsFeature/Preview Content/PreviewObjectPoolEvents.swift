//
//  PreviewObjectPoolEvents.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore
import Foundation

extension PreviewObjectPool {
    var eventItem: EventItem {
        HomeData(events: events(for: .typical)).content(filter: HomeFilter(), at: time).rows[0]
            .event
    }

    var editorPreviews: [EditorPreview] {
        [
            EditorPreview(title: eventTitle, dayCount: DayCount(days: 18, direction: .upcoming)),
            EditorPreview(
                title: "Project kickoff",
                dayCount: DayCount(days: 1_024, direction: .past)
            ),
            EditorPreview(title: "", dayCount: DayCount(days: 0, direction: .today)),
        ]
    }

    var specialNodeChoices: [SpecialNodeChoice] {
        [
            SpecialNodeChoice(
                preset: SpecialNodePreset(kind: .beforeDays, value: 7),
                availability: .available,
                isSelected: true,
                hasNotificationTime: true
            ),
            SpecialNodeChoice(
                preset: SpecialNodePreset(kind: .elapsedDays, value: 100),
                availability: .available,
                isSelected: false,
                hasNotificationTime: true
            ),
            SpecialNodeChoice(
                preset: SpecialNodePreset(kind: .anniversaryYears, value: 1),
                availability: .targetInPast,
                isSelected: false,
                hasNotificationTime: true
            ),
        ]
    }

    var conflictVersions: [EventConflictVersion] {
        [
            EventConflictVersion(id: UUID(), draft: draft(titled: eventTitle), createdAt: now),
            EventConflictVersion(
                id: UUID(),
                draft: draft(titled: "Mia’s Birthday Dinner"),
                createdAt: now.addingTimeInterval(-3_600)
            ),
        ]
    }

    func events(for contents: PreviewContents) -> [CountdownEvent] {
        switch contents {
        case .typical: typicalEvents
        case .singleEvent: [birthday]
        case .empty: []
        case .longTitles: longTitleEvents
        }
    }
}

private extension PreviewObjectPool {
    var birthday: CountdownEvent {
        event(eventTitle, daysFromNow: 18, id: eventID, icon: "birthday.cake", repeatRule: .yearly)
    }

    var typicalEvents: [CountdownEvent] {
        [
            birthday,
            event("Trip to Lisbon", daysFromNow: 123, icon: "airplane"),
            event("New Year", daysFromNow: 186, icon: "star"),
            event("Summer holiday", daysFromNow: -3, icon: "house"),
            event("Project kickoff", daysFromNow: -365, icon: "briefcase"),
        ]
    }

    var longTitleEvents: [CountdownEvent] {
        [
            event(
                "Our first day together in the new home by the old harbour",
                daysFromNow: -1_024,
                id: eventID,
                icon: "house"
            ),
            event(
                "Reise zum Weihnachtsmarkt in Nürnberg mit der ganzen Familie",
                daysFromNow: 1_248,
                icon: "gift"
            ),
        ]
    }

    func draft(titled title: String) -> EventDraft {
        var draft = EventDraft(
            startingOn: now,
            categoryID: BuiltInCategory.important.id,
            timeZone: .gmt
        )
        draft.title = title

        return draft
    }

    func event(
        _ title: String,
        daysFromNow: Double,
        id: CountdownEvent.ID = UUID(),
        icon: String,
        repeatRule: RepeatRule = .never
    ) -> CountdownEvent {
        let date = Calendar(identifier: .gregorian).dateComponents(
            [.year, .month, .day],
            from: now.addingTimeInterval(86_400 * daysFromNow)
        )

        return CountdownEvent(
            id: id,
            title: title,
            year: date.year ?? 2026,
            month: date.month ?? 1,
            day: date.day ?? 1,
            timeZone: .current,
            icon: icon,
            repeatRule: repeatRule,
            createdAt: now,
            updatedAt: now
        )
    }
}
#endif
