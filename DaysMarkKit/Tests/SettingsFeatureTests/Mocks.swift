//
//  Mocks.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import Foundation
import SwiftData
import TestSupport

@testable import DaysMarkCore
@testable import SettingsFeature

extension CategoryEditorTarget {
    static func mock(_ category: EventCategory) -> CategoryEditorTarget {
        .existing(id: category.id, name: category.name, icon: category.icon)
    }
}

extension CountdownEvent {
    static func mock(
        title: String = "Trip",
        deletedAt: Date? = nil,
        permanentDeletionRequestedAt: Date? = nil,
        category: EventCategory? = nil
    ) -> CountdownEvent {
        let event = CountdownEvent(
            title: title,
            year: 2026,
            month: 9,
            day: 1,
            timeZone: .current,
            category: category,
            createdAt: Date(),
            updatedAt: Date()
        )
        event.deletedAt = deletedAt
        event.permanentDeletionRequestedAt = permanentDeletionRequestedAt
        return event
    }
}

extension Date {
    nonisolated static var mockNow: Date {
        .init(timeIntervalSince1970: 1_800_000_000)
    }
}

extension ImportResult {
    nonisolated static var mockNew: ImportResult {
        .mock(id: "new", decision: .create)
    }

    nonisolated static var mockChanged: ImportResult {
        .mock(id: "changed", decision: .change)
    }

    nonisolated static var mockConflict: ImportResult {
        .mock(id: "conflict", decision: .conflict)
    }

    nonisolated static var mockUnchanged: ImportResult {
        .mock(id: "same", decision: .unchanged)
    }

    nonisolated static func mock(id: String, decision: ImportDecision) -> ImportResult {
        .init(
            item: .init(
                sourceKind: .calendar,
                sourceIdentifier: id,
                title: id,
                date: .mockNow,
                repeatsYearly: false,
                calendarSystem: .gregorian,
                timeZone: .gmt,
                includesTime: false
            ),
            eventID: nil,
            decision: decision
        )
    }
}

extension ModelContainer {
    static func mockInMemory() -> ModelContainer {
        try! ModelContainerBuilder(role: .app, storage: .inMemory).makeContainer()
    }
}

extension SettingsDependencies {
    static func mock(
        events: EventRepositorySpy = .init(),
        categories: CategoryRepositorySpy = .init()
    ) -> SettingsDependencies {
        .init(
            events: events,
            categories: categories,
            importScanner: ImportScannerSpy(),
            importApplier: ImportApplierSpy(),
            notificationPermission: NotificationPermissionRequesterSpy(),
            version: "1.0",
            build: "7"
        )
    }
}

extension SwiftDataCategoryRepository {
    static func mock(in container: ModelContainer) -> SwiftDataCategoryRepository {
        let storeChanges = StoreChanges(notificationCenter: NotificationCenter())

        return .init(
            container: container,
            events: SwiftDataEventRepository(
                container: container,
                localSources: nil,
                refresher: SystemSurfaceRefresherSpy(),
                storeChanges: storeChanges,
                now: { .mockNow },
                timeZone: { .gmt }
            ),
            storeChanges: storeChanges,
            now: { .mockNow }
        )
    }
}

extension TimeOfDay {
    nonisolated static var mockNine: TimeOfDay {
        .init(hour: 9, minute: 0)
    }
}
