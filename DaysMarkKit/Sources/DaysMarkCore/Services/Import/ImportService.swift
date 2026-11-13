//
//  ImportService.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation
import SwiftData

@MainActor
public protocol ImportScanning {
    func scan(_ source: ImportScanSource) async throws(ImportError) -> [ImportResult]
}

@MainActor
public protocol ImportApplying {
    func apply(
        _ results: [ImportResult],
        resolutions: [ImportResult.ID: ImportResolution],
        reminders: [ImportResult.ID: ImportReminderConfiguration]
    ) async throws(ImportError)
}

@MainActor
public final class ImportService {
    let container: ModelContainer
    let localSources: ModelContainer?
    let events: EventRepository
    let categories: CategoryRepository

    private(set) var permissionRequest: Task<Void, Never>?

    private let notificationPermission: NotificationPermissionRequesting
    private let refresher: SystemSurfaceRefreshing
    private let now: () -> Date
    private let calendar: () -> Calendar

    public init(
        container: ModelContainer,
        localSources: ModelContainer?,
        events: EventRepository,
        categories: CategoryRepository,
        notificationPermission: NotificationPermissionRequesting,
        refresher: SystemSurfaceRefreshing,
        now: @escaping () -> Date,
        calendar: @escaping () -> Calendar
    ) {
        self.container = container
        self.localSources = localSources
        self.events = events
        self.categories = categories
        self.notificationPermission = notificationPermission
        self.refresher = refresher
        self.now = now
        self.calendar = calendar
    }
}

extension ImportService: ImportScanning {
    public func scan(_ source: ImportScanSource) async throws(ImportError) -> [ImportResult] {
        guard localSources != nil else { throw .localStoreUnavailable }

        do {
            let scanned =
                switch source {
                case .contacts:
                    try await ContactBirthdayScanner().scan(
                        now: now(),
                        timeZone: calendar().timeZone
                    )
                case .calendar:
                    try await CalendarEventScanner().scan(now: now(), calendar: calendar())
                }

            return try results(for: scanned)
        } catch {
            throw ImportError(error)
        }
    }
}

extension ImportService: ImportApplying {
    public func apply(
        _ results: [ImportResult],
        resolutions: [ImportResult.ID: ImportResolution],
        reminders: [ImportResult.ID: ImportReminderConfiguration]
    ) async throws(ImportError) {
        try write(results, resolutions: resolutions, reminders: reminders)

        guard !reminders.isEmpty else { return }

        permissionRequest = Task { [notificationPermission, refresher] in
            await notificationPermission.requestIfNeeded()
            refresher.refresh()
        }
    }
}

public enum ImportScanSource: Equatable, Sendable {
    case contacts
    case calendar
}

public struct ImportReminderConfiguration: Equatable, Sendable {
    public var daysBefore: Int
    public var hour: Int
    public var minute: Int

    public init(daysBefore: Int, hour: Int, minute: Int) {
        self.daysBefore = daysBefore
        self.hour = hour
        self.minute = minute
    }

    var draft: ReminderDraft {
        ReminderDraft(daysBefore: daysBefore, hour: hour, minute: minute)
    }
}
