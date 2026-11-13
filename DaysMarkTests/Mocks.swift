//
//  Mocks.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import Foundation
import SwiftData

extension Date {
    static var mockNow: Date {
        Date(timeIntervalSince1970: 1_800_000_000)
    }
}

struct MockError: Error {}

extension ModelContainer {
    static func mockInMemory() throws -> ModelContainer {
        try ModelContainerBuilder(role: .app, storage: .inMemory).makeContainer()
    }
}

extension OnboardingService {
    static func mock(defaults: UserDefaults) throws -> OnboardingService {
        let container = try ModelContainer.mockInMemory()
        let refresher = SystemSurfaceRefresherSpy()
        let events = SwiftDataEventRepository.mock(in: container, refresher: refresher)

        return OnboardingService(
            events: events,
            categories: SwiftDataCategoryRepository(
                container: container,
                events: events,
                storeChanges: StoreChanges(notificationCenter: NotificationCenter()),
                now: { .mockNow }
            ),
            notificationPermission: ReminderService(
                container: container,
                scheduler: NotificationSchedulerSpy(),
                authorizer: NotificationAuthorizerStub(),
                now: { .mockNow },
                timeZone: { .gmt }
            ),
            refresher: refresher,
            defaults: defaults,
            calendar: Calendar(identifier: .gregorian),
            now: { .mockNow }
        )
    }
}

extension SwiftDataEventRepository {
    static func mock(
        in container: ModelContainer,
        refresher: SystemSurfaceRefreshing = SystemSurfaceRefresherSpy()
    ) -> SwiftDataEventRepository {
        SwiftDataEventRepository(
            container: container,
            localSources: nil,
            refresher: refresher,
            storeChanges: StoreChanges(notificationCenter: NotificationCenter()),
            now: { .mockNow },
            timeZone: { .gmt }
        )
    }
}

extension UserDefaults {
    static func mockEmpty() throws -> UserDefaults {
        let suite = "DaysMarkTests.\(UUID().uuidString)"

        guard let defaults = UserDefaults(suiteName: suite) else {
            throw MockError()
        }

        defaults.removePersistentDomain(forName: suite)

        return defaults
    }
}
