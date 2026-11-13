//
//  ReminderService.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation
import OSLog
import SwiftData

public protocol NotificationPermissionRequesting: Sendable {
    func currentPermission() async -> NotificationPermission
    @discardableResult
    func requestIfNeeded() async -> NotificationPermission
}

public enum NotificationPermission: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
}

@MainActor
public final class ReminderService {
    private let container: ModelContainer
    private let scheduler: NotificationScheduling
    private let authorizer: NotificationAuthorizing
    private let now: () -> Date
    private let timeZone: () -> TimeZone
    private let planner = ReminderPlanner()
    private let reconciler: ReminderReconciler

    private var inFlight: Task<Void, Never>?

    public init(
        container: ModelContainer,
        scheduler: NotificationScheduling,
        authorizer: NotificationAuthorizing,
        now: @escaping () -> Date,
        timeZone: @escaping () -> TimeZone
    ) {
        self.container = container
        self.scheduler = scheduler
        self.authorizer = authorizer
        self.now = now
        self.timeZone = timeZone
        reconciler = ReminderReconciler(scheduler: scheduler)
    }

    private var context: ModelContext { container.mainContext }

    public func registerCategories() async {
        await scheduler.registerCategories()
    }

    public func reconcile() async {
        let pass = enqueuePass()

        await withTaskCancellationHandler {
            await pass.value
        } onCancel: {
            pass.cancel()
        }
    }

    private func enqueuePass() -> Task<Void, Never> {
        let previous = inFlight
        let pass = Task {
            await previous?.value
            await runPass()
        }
        inFlight = pass

        return pass
    }

    private func runPass() async {
        do {
            let visible = FetchDescriptor<CountdownEvent>(
                predicate: #Predicate { $0.deletedAt == nil }
            )
            let planned = planner.plan(
                for: try context.fetch(visible),
                now: now(),
                userTimeZone: timeZone(),
                focusedEventID: FocusSelectionResolver().selectedEventID(
                    selections: try context.fetch(FetchDescriptor<FocusSelection>()),
                    revisions: try context.fetch(FetchDescriptor<FocusSelectionRevision>())
                )
            )

            await reconciler.reconcile(planned)
        } catch {
            Logger(category: .data).error(
                "Failed to read events; reminder reconciliation skipped: \(error.localizedDescription, privacy: .public)"
            )
        }
    }
}

extension ReminderService: NotificationPermissionRequesting {
    public func currentPermission() async -> NotificationPermission {
        await authorizer.currentPermission()
    }

    @discardableResult
    public func requestIfNeeded() async -> NotificationPermission {
        let current = await currentPermission()

        guard current == .notDetermined else { return current }

        do {
            return try await authorizer.requestAuthorization() ? .authorized : .denied
        } catch {
            Logger(category: .data).error(
                "Notification authorization failed: \(error.localizedDescription, privacy: .public)"
            )
            return .notDetermined
        }
    }
}
