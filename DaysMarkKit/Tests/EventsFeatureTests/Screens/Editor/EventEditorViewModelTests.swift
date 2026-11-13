//
//  EventEditorViewModelTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import TestSupport
import Testing

@testable import DaysMarkCore
@testable import EventsFeature

struct EventEditorViewModelTests {
    @Test func initForANewEventThenStartsFromTheCategoryAndToday() {
        // Given / When
        let viewModel = EventEditorViewModel.mock(
            target: .new(categoryID: BuiltInCategory.birthday.id)
        )

        // Then
        #expect(viewModel.isNew)
        #expect(viewModel.draft.categoryID == BuiltInCategory.birthday.id)
        #expect(viewModel.draft.targetDate == .mockNow)
        #expect(!viewModel.hasUnsavedChanges)
    }

    @Test func reloadThenPrefillsTheDraftFromTheStoredEvent() {
        // Given
        let event = CountdownEvent.mock(
            title: "Wedding",
            year: 2030,
            month: 6,
            day: 1,
            repeatRule: .yearly
        )
        let viewModel = EventEditorViewModel.mock(
            target: .existing(event.id),
            events: EventRepositorySpy(storedEvents: [event])
        )

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.draft.title == "Wedding")
        #expect(viewModel.draft.repeatRule == .yearly)
        #expect(viewModel.canSave)
        #expect(!viewModel.isNew)
    }

    @Test func reloadAgainThenKeepsTheDraftBeingEdited() {
        // Given
        let event = CountdownEvent.mock("Trip")
        let viewModel = EventEditorViewModel.mock(
            target: .existing(event.id),
            events: EventRepositorySpy(storedEvents: [event])
        )
        viewModel.reload()
        viewModel.draft.title = "Changed"

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.draft.title == "Changed")
    }

    @Test func reloadForANewEventThenKeepsTheNewDraft() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = EventEditorViewModel.mock(router: router)

        // When
        viewModel.reload()

        // Then
        #expect(router.calls.isEmpty)
        #expect(viewModel.draft.title.isEmpty)
        #expect(!viewModel.hasUnsavedChanges)
    }

    @Test func hasUnsavedChangesThenFollowsTheDraftAndLeavesTheEventAlone() {
        // Given
        let event = CountdownEvent.mock("Trip")
        let viewModel = EventEditorViewModel.mock(
            target: .existing(event.id),
            events: EventRepositorySpy(storedEvents: [event])
        )
        viewModel.reload()

        // When
        viewModel.draft.title = "Changed"
        let whileChanged = viewModel.hasUnsavedChanges
        viewModel.draft.title = "Trip"

        // Then
        #expect(whileChanged)
        #expect(!viewModel.hasUnsavedChanges)
        #expect(event.title == "Trip")
    }

    @Test func previewForARepeatingPastEventThenCountsDown() {
        // Given
        let viewModel = EventEditorViewModel.mock()
        viewModel.draft.targetDate = .distantPast

        // When
        viewModel.selectRepeatRule(.yearly)

        // Then
        #expect(viewModel.preview?.dayCount.direction != .past)
    }

    @Test func previewForAPastEventThatDoesNotRepeatThenCountsUp() {
        // Given
        let viewModel = EventEditorViewModel.mock()

        // When
        viewModel.moveTargetDate(to: Date.mockNow.addingTimeInterval(-86_400 * 30))

        // Then
        #expect(viewModel.preview?.dayCount == DayCount(days: 30, direction: .past))
        #expect(viewModel.preview?.title == "")
    }

    @Test func canSaveThenNeedsATitleThatIsNotBlank() {
        // Given
        let viewModel = EventEditorViewModel.mock()
        let untitled = viewModel.canSave

        // When
        viewModel.draft.title = "   "
        let blank = viewModel.canSave
        viewModel.draft.title = "Trip"

        // Then
        #expect(!untitled)
        #expect(!blank)
        #expect(viewModel.canSave)
    }

    @Test func toggleEndDateThenAddsItOnTheStartDayAndRemovesIt() {
        // Given
        let viewModel = EventEditorViewModel.mock()

        // When
        viewModel.toggleEndDate(true)
        let added = viewModel.draft.endDate
        viewModel.toggleEndDate(false)

        // Then
        #expect(added == viewModel.draft.targetDate)
        #expect(viewModel.draft.endDate == nil)
        #expect(!viewModel.hasEndDate)
        #expect(viewModel.endDate == viewModel.draft.targetDate)
    }

    @Test func moveEndDateThenKeepsTheChosenEnd() {
        // Given
        let viewModel = EventEditorViewModel.mock()
        let end = Date.mockNow.addingTimeInterval(86_400 * 3)
        viewModel.toggleEndDate(true)

        // When
        viewModel.moveEndDate(to: end)

        // Then
        #expect(viewModel.endDate == end)
        #expect(viewModel.hasEndDate)
    }

    @Test func moveTargetDateThenClearsTheEndDate() {
        // Given
        let viewModel = EventEditorViewModel.mock()
        viewModel.toggleEndDate(true)

        // When
        viewModel.moveTargetDate(to: Date.mockNow.addingTimeInterval(86_400 * 30))

        // Then
        #expect(viewModel.draft.endDate == nil)
        #expect(!viewModel.hasEndDate)
    }

    @Test func addReminderForAnAllDayEventThenUsesTheDefaultTime() {
        // Given
        let viewModel = EventEditorViewModel.mock()

        // When
        viewModel.addReminder(at: TimeOfDay(hour: 7, minute: 45))

        // Then
        #expect(viewModel.draft.reminders.first?.kind == .allDayOffsetAtTime)
        #expect(viewModel.draft.reminders.first?.hour == 7)
        #expect(viewModel.draft.reminders.first?.minute == 45)
        #expect(viewModel.permissionRequest != nil)
    }

    @Test func addReminderForATimedEventThenRemindsAtTheEventTime() {
        // Given
        let viewModel = EventEditorViewModel.mock()
        viewModel.toggleTime(true)

        // When
        viewModel.addReminder(at: TimeOfDay(hour: 7, minute: 45))

        // Then
        #expect(viewModel.hasTime)
        #expect(viewModel.draft.reminders.first?.kind == .exactTimeOffset)
        #expect(viewModel.draft.reminders.first?.minutesBefore == 0)
    }

    @Test func toggleTimeThenRewritesRemindersForTheNewKindOfDate() {
        // Given
        let viewModel = EventEditorViewModel.mock()
        viewModel.addReminder(at: TimeOfDay(hour: 9, minute: 0))

        // When
        viewModel.toggleTime(true)
        let timed = viewModel.draft.reminders.first
        viewModel.toggleTime(false)

        // Then
        #expect(timed?.kind == .exactTimeOffset)
        #expect(timed?.minutesBefore == 0)
        #expect(viewModel.draft.timeSemantics == .floatingAllDay)
        #expect(viewModel.draft.reminders.first?.kind == .allDayOffsetAtTime)
        #expect(viewModel.draft.reminders.first?.minutesBefore == nil)
    }

    @Test func removeRemindersThenDropsTheChosenRows() {
        // Given
        let viewModel = EventEditorViewModel.mock()
        viewModel.addReminder(at: TimeOfDay(hour: 9, minute: 0))
        viewModel.addReminder(at: TimeOfDay(hour: 10, minute: 0))

        // When
        viewModel.removeReminders(at: [0])

        // Then
        #expect(viewModel.draft.reminders.map(\.hour) == [10])
    }

    @Test func requestNotificationPermissionThenAsksOnlyAfterAReminderWasAdded() async {
        // Given
        let permissionRequester = NotificationPermissionRequesterSpy()
        let viewModel = EventEditorViewModel.mock(permissionRequester: permissionRequester)

        // When
        await viewModel.requestNotificationPermission()
        let beforeAReminder = permissionRequester.requestCount
        viewModel.addReminder(at: TimeOfDay(hour: 9, minute: 0))
        await viewModel.requestNotificationPermission()

        // Then
        #expect(beforeAReminder == 0)
        #expect(permissionRequester.requestCount == 1)
    }

    @Test func selectCalendarSystemThenAppliesWithoutAConfirmation() {
        // Given
        let viewModel = EventEditorViewModel.mock()
        viewModel.draft.title = "Ramadan"

        // When
        viewModel.selectCalendarSystem(.islamicUmmAlQura)

        // Then
        #expect(viewModel.draft.calendarSystem == .islamicUmmAlQura)
        #expect(viewModel.draft.islamicObservationConfirmed)
        #expect(viewModel.canSave)
    }

    @Test func datePickerCalendarThenUsesTheEventsTimeZone() throws {
        // Given
        let eventZone = try #require(TimeZone(identifier: "Pacific/Kiritimati"))
        let event = CountdownEvent.mock(
            title: "Remote call",
            year: 2030,
            month: 1,
            day: 2,
            hour: 1,
            minute: 30,
            timeZone: eventZone,
            timeSemantics: .fixedInstant
        )
        let viewModel = EventEditorViewModel.mock(
            target: .existing(event.id),
            events: EventRepositorySpy(storedEvents: [event])
        )
        viewModel.reload()

        // When
        let components = viewModel.datePickerCalendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: viewModel.draft.targetDate
        )

        // Then
        #expect(viewModel.datePickerCalendar.timeZone == eventZone)
        #expect(components == DateComponents(year: 2030, month: 1, day: 2, hour: 1, minute: 30))
    }

    @Test func saveANewEventThenStoresTheDraftAndDismisses() {
        // Given
        let events = EventRepositorySpy()
        let router = EventsRouterSpy()
        let viewModel = EventEditorViewModel.mock(events: events, router: router)
        viewModel.draft.title = "Trip"

        // When
        viewModel.save()

        // Then
        #expect(events.saves == [EventRepositorySpy.Save(eventID: nil, draft: viewModel.draft)])
        #expect(router.calls == [.dismissSheet])
        #expect(viewModel.issue == nil)
    }

    @Test func saveAnExistingEventThenReplacesIt() {
        // Given
        let event = CountdownEvent.mock("Trip")
        let events = EventRepositorySpy(storedEvents: [event])
        let viewModel = EventEditorViewModel.mock(target: .existing(event.id), events: events)
        viewModel.reload()

        // When
        viewModel.save()

        // Then
        #expect(events.saves.map(\.eventID) == [event.id])
    }

    @Test func saveWhenItFailsThenKeepsTheSheetAndReportsTheIssue() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = EventEditorViewModel.mock(
            events: EventRepositorySpy(error: .emptyTitle),
            router: router
        )

        // When
        viewModel.save()
        let failed = viewModel.issue
        viewModel.acknowledgeIssue()

        // Then
        #expect(failed == .emptyTitle)
        #expect(viewModel.issue == nil)
        #expect(router.calls.isEmpty)
    }

    @Test func deleteThenMovesTheEventToRecentlyDeletedAndDismisses() {
        // Given
        let events = EventRepositorySpy()
        let router = EventsRouterSpy()
        let viewModel = EventEditorViewModel.mock(
            target: .existing(.mockActive),
            events: events,
            router: router
        )

        // When
        viewModel.delete()

        // Then
        #expect(events.deletedIDs == [.mockActive])
        #expect(router.calls == [.dismissSheet])
    }

    @Test func deleteWhenItFailsThenKeepsTheSheetAndReportsTheIssue() {
        // Given
        let events = EventRepositorySpy(failingIDs: [.mockActive], error: .storeFailure)
        let router = EventsRouterSpy()
        let viewModel = EventEditorViewModel.mock(
            target: .existing(.mockActive),
            events: events,
            router: router
        )

        // When
        viewModel.delete()

        // Then
        #expect(viewModel.issue == .actionFailed)
        #expect(router.calls.isEmpty)
        #expect(events.saves.isEmpty)
    }

    @Test func deleteANewEventThenDoesNothing() {
        // Given
        let events = EventRepositorySpy()
        let viewModel = EventEditorViewModel.mock(events: events)

        // When
        viewModel.delete()

        // Then
        #expect(events.deletedIDs.isEmpty)
    }

    @Test func cancelAndEditSpecialNodesThenRoute() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = EventEditorViewModel.mock(router: router)

        // When
        viewModel.editSpecialNodes()
        viewModel.cancel()

        // Then
        #expect(router.calls == [.specialNodes, .dismissSheet])
    }

    @Test func reloadThenOffersEveryStoredCategoryThatIsNotDeleted() {
        // Given
        let travel = EventCategory(name: "Travel")
        let deleted = EventCategory(name: "Deleted")
        deleted.deletedAt = .mockNow
        let viewModel = EventEditorViewModel.mock(
            categories: CategoryRepositorySpy(storedCategories: [travel, deleted])
        )

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.categoryChoices.map(\.id) == [travel.id])
    }

    @Test func reloadWhenTheStoreFailsThenReportsTheIssue() {
        // Given
        let viewModel = EventEditorViewModel.mock(
            categories: CategoryRepositorySpy(readError: .storeFailure)
        )

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.issue == .actionFailed)
    }
}
