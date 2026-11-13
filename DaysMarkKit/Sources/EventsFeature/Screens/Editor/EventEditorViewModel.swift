//
//  EventEditorViewModel.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class EventEditorViewModel {
    var draft: EventDraft

    let now: () -> Date
    let calendar: Calendar
    private let target: EditorTarget
    private let events: EventRepository
    private let categories: CategoryRepository
    private let permissionRequester: NotificationPermissionRequesting
    private let router: EventsRouting

    private(set) var initialDraft: EventDraft
    private(set) var categoryChoices: [EventCategory] = []
    private(set) var permissionRequest: UUID?
    private(set) var issue: EventIssue?

    var title: LocalizedStringResource {
        switch isNew {
        case true: LocalizedStringResource("editor.title.new", bundle: .module)
        case false: LocalizedStringResource("editor.title.edit", bundle: .module)
        }
    }

    var isNew: Bool {
        target.eventID == nil
    }

    var hasUnsavedChanges: Bool {
        draft != initialDraft
    }

    var canSave: Bool {
        draft.isValid && draft.specialReminderNodes.allSatisfy(canKeep)
    }

    var preview: EditorPreview? {
        draft.dayCount(at: now(), in: calendar.timeZone).map {
            EditorPreview(title: draft.title, dayCount: $0)
        }
    }

    var datePickerCalendar: Calendar {
        var calendar = Calendar(identifier: draft.calendarSystem.identifier)
        calendar.timeZone = draft.timeZone

        return calendar
    }

    var hasTime: Bool {
        draft.timeSemantics != .floatingAllDay
    }

    var hasEndDate: Bool {
        draft.endDate != nil
    }

    var endDate: Date {
        draft.endDate ?? draft.targetDate
    }

    init(
        target: EditorTarget,
        events: EventRepository,
        categories: CategoryRepository,
        permissionRequester: NotificationPermissionRequesting,
        calendar: Calendar,
        now: @escaping () -> Date,
        router: EventsRouting
    ) {
        let draft = EventDraft(
            startingOn: now(),
            categoryID: target.categoryID,
            timeZone: calendar.timeZone
        )

        self.target = target
        self.events = events
        self.categories = categories
        self.permissionRequester = permissionRequester
        self.calendar = calendar
        self.now = now
        self.router = router
        self.draft = draft
        initialDraft = draft
    }

    func observeStore() async {
        reload()

        for await _ in events.changes() {
            reload()
        }
    }

    func reload() {
        guard !hasUnsavedChanges else { return }

        do {
            categoryChoices = try categories.categories().filter { $0.deletedAt == nil }

            if let event = try editedEvent() {
                startEditing(event)
            }
        } catch {
            issue = EventIssue(.storeFailure)
        }
    }

    private func editedEvent() throws(EventError) -> CountdownEvent? {
        guard let eventID = target.eventID else { return nil }

        return try events.events().first { $0.id == eventID && $0.deletedAt == nil }
    }

    private func startEditing(_ event: CountdownEvent) {
        draft = EventDraft(event, at: now(), in: calendar.timeZone)
        initialDraft = draft
    }

    func moveTargetDate(to date: Date) {
        draft.targetDate = date
        draft.endDate = nil
        removeUnavailableSpecialNodes()
    }

    func toggleTime(_ isOn: Bool) {
        draft.timeSemantics = isOn ? .floatingLocalTime : .floatingAllDay
        draft.timeSemanticsChanged()
    }

    func toggleEndDate(_ isOn: Bool) {
        draft.endDate = isOn ? draft.targetDate : nil
    }

    func moveEndDate(to date: Date) {
        draft.endDate = date
    }

    func selectRepeatRule(_ rule: RepeatRule) {
        draft.repeatRule = rule
        removeUnavailableSpecialNodes()
    }

    func selectCalendarSystem(_ system: EventCalendarSystem) {
        draft.calendarSystem = system
        draft.islamicObservationConfirmed = true
    }

    func addReminder(at defaultTime: TimeOfDay) {
        let reminder =
            switch draft.timeSemantics {
            case .floatingAllDay:
                ReminderDraft(
                    kind: .allDayOffsetAtTime,
                    hour: defaultTime.hour,
                    minute: defaultTime.minute
                )
            case .fixedInstant, .floatingLocalTime:
                ReminderDraft(kind: .exactTimeOffset, minutesBefore: 0)
            }

        draft.reminders.append(reminder)
        askForNotificationPermission()
    }

    func removeReminders(at offsets: IndexSet) {
        draft.removeReminders(atOffsets: offsets)
    }

    func requestNotificationPermission() async {
        guard permissionRequest != nil else { return }

        await permissionRequester.requestIfNeeded()
    }

    func editSpecialNodes() {
        router.showSpecialNodes()
    }

    func save() {
        do {
            try events.save(draft, replacing: target.eventID)
            router.dismissSheet()
        } catch {
            issue = EventIssue(error)
        }
    }

    func delete() {
        guard let eventID = target.eventID else { return }

        do {
            try events.delete(eventID: eventID)
            router.dismissSheet()
        } catch {
            issue = EventIssue(error)
        }
    }

    func cancel() {
        router.dismissSheet()
    }

    func acknowledgeIssue() {
        issue = nil
    }

    func askForNotificationPermission() {
        permissionRequest = UUID()
    }
}
