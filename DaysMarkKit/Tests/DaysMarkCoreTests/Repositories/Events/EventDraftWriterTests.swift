//
//  EventDraftWriterTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct SwiftDataEventRepositoryDraftsTests {
    @Test
    func createThenSplitsTheDateIntoComponents() throws {
        // Given
        let utc = try #require(TimeZone(identifier: "UTC"))
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.targetDate = try date(2026, 8, 20, timeZone: utc)
        draft.timeZone = utc

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.targetYear == 2026)
        #expect(event.targetMonth == 8)
        #expect(event.targetDay == 20)

        #expect(event.timeZone == utc)
    }

    @Test
    func createThenSplitsTheDateInTheDraftsTimeZone() throws {
        // Given
        let tokyo = try #require(TimeZone(identifier: "Asia/Tokyo"))
        let utc = try #require(TimeZone(identifier: "UTC"))
        let (service, _) = try makeService()

        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.targetDate = try date(2026, 8, 20, hour: 7, timeZone: tokyo)

        draft.timeZone = tokyo
        let inTokyo = try service.create(from: draft)

        // When
        draft.timeZone = utc
        let inUTC = try service.create(from: draft)

        // Then
        #expect(inTokyo.targetDay == 20)
        #expect(inUTC.targetDay == 19)
    }

    @Test
    func createWhenTheTitleIsBlankThenThrowsEmptyTitle() throws {
        // Given
        let (service, context) = try makeService()
        var draft = EventDraft.mock
        draft.title = "   "

        // When / Then
        #expect(throws: EventError.emptyTitle) {
            try service.create(from: draft)
        }
        #expect(try context.fetch(FetchDescriptor<CountdownEvent>()).isEmpty)
    }

    @Test
    func updateWhenTheEventIsDeletedThenThrowsInRecentlyDeleted() throws {
        let utc = try #require(TimeZone(identifier: "UTC"))
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.targetDate = try date(2026, 8, 20, timeZone: utc)
        draft.timeZone = utc
        let event = try service.create(from: draft)
        try service.delete(eventID: event.id)

        draft.title = "Trip 2"
        #expect(throws: EventError.inRecentlyDeleted) {
            try service.save(draft, replacing: event.id)
        }
    }

    @Test
    func createThenTrimsTheTitle() throws {
        // Given
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "  Trip  "

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.title == "Trip")
    }

    @Test
    func createWithoutAnEndDateThenStoresNoEnd() throws {
        // Given
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Trip"

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.endComponents == nil)
    }

    @Test
    func createWithAnEndDateThenStoresItsComponents() throws {
        // Given
        let utc = try #require(TimeZone(identifier: "UTC"))
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Holiday"
        draft.targetDate = try date(2026, 7, 1, timeZone: utc)
        draft.endDate = try date(2026, 7, 14, timeZone: utc)
        draft.timeZone = utc

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.endComponents?.day == 14)
    }

    @Test
    func createThenLinksTheCategoryByID() throws {
        // Given
        let (service, context) = try makeService()
        let category = EventCategory(name: "Travel")
        context.insert(category)
        try context.save()
        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.categoryID = category.id

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.category?.id == category.id)
    }

    @Test
    func createWhenTheCategoryIsUnknownThenKeepsItsIDAndShowsImportant() throws {
        // Given
        let (service, _) = try makeService()
        let missingCategoryID = UUID()
        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.categoryID = missingCategoryID

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.categoryID == missingCategoryID)
        #expect(event.category?.builtInKind == .important)
        #expect(event.title == "Trip")
    }

    @Test
    func updateWhenTheCategoryIsUnknownThenKeepsItsID() throws {
        // Given
        let (service, context) = try makeService()
        let missingCategoryID = UUID()
        let important = EventCategory(builtIn: .important)
        context.insert(important)
        let event = CountdownEvent.mock(
            title: "Trip",
            year: 2027,
            month: 6,
            day: 1,
            category: important
        )
        event.categoryID = missingCategoryID
        context.insert(event)
        EventRevisionWriter(context: context).appendInitialRevision(for: event, at: .mockNow)
        try context.save()

        // When
        var draft = EventDraft.mock(of: event)
        draft.title = "Edited trip"
        try service.save(draft, replacing: event.id)

        // Then
        #expect(event.categoryID == missingCategoryID)
        #expect(event.category?.id == BuiltInCategory.important.id)
        #expect(event.title == "Edited trip")
    }

    @Test
    func updateThenWritesTheDraftAndTouchesTheEvent() throws {
        // Given
        let utc = try #require(TimeZone(identifier: "UTC"))
        var now = Date.mockNow
        let service = SwiftDataEventRepository.mock(in: .mockInMemory(), now: { now })
        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.timeZone = utc
        draft.targetDate = try date(2026, 8, 20, timeZone: utc)
        let event = try service.create(from: draft)
        let originalUpdatedAt = event.updatedAt
        now += 60

        // When
        draft.title = "Trip to Berlin"
        draft.targetDate = try date(2026, 9, 1, timeZone: utc)
        draft.repeatRule = .yearly
        try service.save(draft, replacing: event.id)

        // Then
        #expect(event.title == "Trip to Berlin")
        #expect(event.targetMonth == 9)
        #expect(event.repeatRule == .yearly)
        #expect(event.updatedAt == originalUpdatedAt.addingTimeInterval(60))
    }

    @Test
    func updateWhenTheTitleIsBlankThenThrowsEmptyTitle() throws {
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Trip"
        let event = try service.create(from: draft)

        draft.title = ""
        #expect(throws: EventError.emptyTitle) {
            try service.save(draft, replacing: event.id)
        }
        #expect(event.title == "Trip")
    }

    @Test
    func updateWhenTheCategoryIsClearedThenUsesImportant() throws {
        // Given
        let (service, context) = try makeService()
        let category = EventCategory(name: "Travel")
        context.insert(category)
        try context.save()
        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.categoryID = category.id
        let event = try service.create(from: draft)

        // When
        draft.categoryID = nil
        try service.save(draft, replacing: event.id)

        // Then
        #expect(event.categoryID == BuiltInCategory.important.id)
        #expect(event.category?.builtInKind == .important)
    }

    @Test
    func createThenStoresTheReminders() throws {
        // Given
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.reminders = [ReminderDraft(daysBefore: 0, hour: 9), ReminderDraft(daysBefore: 7)]

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.reminders?.count == 2)
    }

    @Test
    func updateThenKeepsTheIdentityOfAReminder() throws {
        // Given
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Trip"
        let reminderID = UUID()
        draft.reminders = [ReminderDraft(id: reminderID, daysBefore: 0, hour: 9)]
        let event = try service.create(from: draft)

        // When
        draft.reminders = [ReminderDraft(id: reminderID, daysBefore: 3, hour: 20)]
        try service.save(draft, replacing: event.id)

        // Then
        #expect(event.reminders?.count == 1)
        #expect(event.reminders?.first?.id == reminderID)
        #expect(event.reminders?.first?.daysBefore == 3)
        #expect(event.reminders?.first?.hour == 20)
    }

    @Test
    func updateThenRemovesTheDroppedReminders() throws {
        // Given
        let (service, context) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Trip"
        let keep = ReminderDraft(daysBefore: 0)
        draft.reminders = [keep, ReminderDraft(daysBefore: 7)]
        let event = try service.create(from: draft)

        // When
        draft.reminders = [keep]
        try service.save(draft, replacing: event.id)

        // Then
        #expect(event.reminders?.count == 1)
        #expect(try context.fetch(FetchDescriptor<ReminderRule>()).count == 1)
    }

    @Test
    func updateThenInsertsTheNewReminders() throws {
        // Given
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Trip"
        draft.reminders = [ReminderDraft(daysBefore: 0)]
        let event = try service.create(from: draft)

        // When
        draft.reminders.append(ReminderDraft(daysBefore: 7))
        try service.save(draft, replacing: event.id)

        // Then
        #expect(event.reminders?.count == 2)
    }

    @Test
    func createWhenTimedThenStoresTheReminderAsMinutesBefore() throws {
        // Given
        let utc = try #require(TimeZone(identifier: "UTC"))
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Launch"
        draft.timeZone = utc
        draft.targetDate = try date(2027, 4, 10, hour: 15, timeZone: utc)
        draft.timeSemantics = .fixedInstant
        draft.reminders = [ReminderDraft(kind: .exactTimeOffset, minutesBefore: 45)]

        // When
        let event = try service.create(from: draft)
        let reminder = try #require(event.reminders?.first)

        // Then
        #expect(event.timeSemantics == .fixedInstant)
        #expect(event.targetHour == 15)
        #expect(event.utcOffsetSecondsAtCreation == 0)
        #expect(reminder.kind == .exactTimeOffset)
        #expect(reminder.minutesBefore == 45)
        #expect(reminder.daysBefore == 0)
    }

    @Test
    func createWhenAFixedInstantHasAnEndThenStoresTheDuration() throws {
        // Given
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = berlin
        let start = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 3, day: 28, hour: 9))
        )
        let end = try #require(
            calendar.date(from: DateComponents(year: 2026, month: 3, day: 30, hour: 9))
        )
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Conference"
        draft.targetDate = start
        draft.endDate = end
        draft.timeZone = berlin
        draft.timeSemantics = .fixedInstant

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.utcOffsetSecondsAtCreation == 3_600)
        #expect(event.endUTCOffsetSecondsAtCreation == 7_200)
        #expect(event.rangeDurationSeconds == TimeInterval(47 * 60 * 60))
        #expect(event.rangeCalendarDaySpan == nil)
    }

    @Test
    func createWithAChineseDateThenStoresTheCompleteSpecification() throws {
        // Given
        let shanghai = try #require(TimeZone(identifier: "Asia/Shanghai"))
        var chinese = Calendar(identifier: .chinese)
        chinese.timeZone = shanghai
        let selected = try #require(
            chinese.date(
                from: DateComponents(
                    calendar: chinese,
                    timeZone: shanghai,
                    era: 78,
                    year: 40,
                    month: 2,
                    day: 1
                )
            )
        )
        let (service, _) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Lunar date"
        draft.calendarSystem = .chinese
        draft.timeZone = shanghai
        draft.targetDate = selected

        // When
        let event = try service.create(from: draft)

        // Then
        #expect(event.calendarSystem == .chinese)
        #expect(event.targetEra != nil)
        #expect(
            event.startDateSpecification.resolvedDate(
                semantics: .floatingAllDay,
                eventTimeZone: nil,
                userTimeZone: shanghai
            ) != nil
        )
    }

    @Test
    func createThenStoresTheSpecialNodesAndTheirSnapshot() throws {
        // Given
        let (service, context) = try makeService()
        var draft = EventDraft.mock
        draft.title = "Wedding"
        let nodeID = UUID()
        draft.specialReminderNodes = [
            SpecialReminderNodeDraft(id: nodeID, kind: .anniversaryYears, value: 5)
        ]
        draft.specialNodeNotificationMinuteOfDay = 8 * 60 + 30

        // When
        let event = try service.create(from: draft)
        let node = try #require(event.specialReminderNodes?.first)
        let revision = try #require(
            context.fetch(FetchDescriptor<EventRevision>()).first(where: { $0.id == event.id })
        )

        // Then
        #expect(node.id == nodeID)
        #expect(node.kind == .anniversaryYears)
        #expect(node.value == 5)
        #expect(event.specialNodeNotificationHour == 8)
        #expect(event.specialNodeNotificationMinute == 30)
        #expect(revision.specialNodeSnapshotData != nil)
    }
}

private extension SwiftDataEventRepositoryDraftsTests {
    func makeService() throws -> (SwiftDataEventRepository, ModelContext) {
        let container = ModelContainer.mockInMemory()

        return (SwiftDataEventRepository.mock(in: container), container.mainContext)
    }

    func date(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 12,
        timeZone: TimeZone
    ) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return try #require(
            calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))
        )
    }
}
