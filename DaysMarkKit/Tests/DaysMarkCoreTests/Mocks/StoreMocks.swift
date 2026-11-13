//
//  StoreMocks.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import SwiftData
import TestSupport

@testable import DaysMarkCore

extension EventLookup {
    static func mock(in container: ModelContainer) -> EventLookup {
        EventLookup(
            container: container,
            now: { .mockNow },
            timeZone: { .mockUTC },
            locale: { .mockAmericanEnglish }
        )
    }
}

extension EventRepair {
    static func mockSeeded(in context: ModelContext) throws -> EventRepair {
        try SwiftDataCategoryRepository.mock(in: context.container).seedBuiltInCategories()

        return EventRepair(context: context)
    }
}

extension ImportService {
    static func mock(
        in container: ModelContainer,
        localSources: ModelContainer?,
        events: EventRepository? = nil,
        categories: CategoryRepository? = nil,
        notificationPermission: NotificationPermissionRequesting =
            NotificationPermissionRequesterSpy(),
        refresher: SystemSurfaceRefreshing = SystemSurfaceRefresherSpy()
    ) -> ImportService {
        ImportService(
            container: container,
            localSources: localSources,
            events: events ?? SwiftDataEventRepository.mock(in: container, refresher: refresher),
            categories: categories ?? SwiftDataCategoryRepository.mock(in: container),
            notificationPermission: notificationPermission,
            refresher: refresher,
            now: { .mockNow },
            calendar: { .mockGregorianUTC }
        )
    }
}

extension ModelConfiguration {
    static func mockOnDisk(at url: URL) -> ModelConfiguration {
        ModelConfiguration(
            StoreIdentifier.configuration.rawValue,
            schema: .mockCurrent,
            url: url,
            allowsSave: true,
            cloudKitDatabase: .none
        )
    }

    static func mockReadOnly(at url: URL) -> ModelConfiguration {
        ModelContainerBuilder(role: .widget, storage: .appGroup).configuration(at: url)
    }
}

extension ModelContainer {
    static func mockInMemory() -> ModelContainer {
        try! ModelContainerBuilder(role: .app, storage: .inMemory).makeContainer()
    }

    static func mockLocalSources() -> ModelContainer {
        try! ModelContainerBuilder(role: .app, storage: .inMemory).openLocalSourceContainer()
    }
}

extension OnboardingService {
    static func mock(
        in container: ModelContainer = .mockInMemory(),
        events: EventRepository? = nil,
        categories: CategoryRepository? = nil,
        notificationPermission: NotificationPermissionRequesting =
            NotificationPermissionRequesterSpy(),
        refresher: SystemSurfaceRefreshing = SystemSurfaceRefresherSpy(),
        defaults: UserDefaults = .mockEmpty(),
        calendar: Calendar = .mockGregorianUTC
    ) -> OnboardingService {
        OnboardingService(
            events: events ?? SwiftDataEventRepository.mock(in: container, refresher: refresher),
            categories: categories ?? SwiftDataCategoryRepository.mock(in: container),
            notificationPermission: notificationPermission,
            refresher: refresher,
            defaults: defaults,
            calendar: calendar,
            now: { .mock(2026, 9, 3, hour: 0) }
        )
    }
}

extension Schema {
    static var mockCurrent: Schema {
        ModelContainerBuilder(role: .app, storage: .inMemory).schema
    }

    static var mockLocalSources: Schema {
        ModelContainerBuilder(role: .app, storage: .inMemory).localSourceSchema
    }
}

extension SwiftDataCategoryRepository {
    static func mock(in container: ModelContainer) -> SwiftDataCategoryRepository {
        SwiftDataCategoryRepository(
            container: container,
            events: SwiftDataEventRepository.mock(in: container),
            storeChanges: StoreChanges(notificationCenter: NotificationCenter()),
            now: { .mockNow }
        )
    }
}

extension SwiftDataEventRepository {
    static func mock(
        in container: ModelContainer,
        localSources: ModelContainer? = nil,
        refresher: SystemSurfaceRefreshing = SystemSurfaceRefresherSpy(),
        now: @escaping () -> Date = { .mockNow }
    ) -> SwiftDataEventRepository {
        SwiftDataEventRepository(
            container: container,
            localSources: localSources,
            refresher: refresher,
            storeChanges: StoreChanges(notificationCenter: NotificationCenter()),
            now: now,
            timeZone: { .mockUTC }
        )
    }
}

extension SwiftDataEventRepository {
    func create(from draft: EventDraft) throws -> CountdownEvent {
        let id = try save(draft, replacing: nil)

        guard let event = try events().first(where: { $0.id == id }) else {
            throw EventError.eventUnavailable
        }

        return event
    }
}

extension UserDefaults {
    static func mockEmpty() -> UserDefaults {
        let suite = "DaysMarkCoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)

        return defaults
    }
}
