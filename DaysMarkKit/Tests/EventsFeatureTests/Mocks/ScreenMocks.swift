//
//  ScreenMocks.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import Foundation
import SettingsFeature
import TestSupport

@testable import EventsFeature

extension EventEditorViewModel {
    static func mock(
        target: EditorTarget = .new(categoryID: BuiltInCategory.important.id),
        events: EventRepositorySpy = .init(),
        categories: CategoryRepositorySpy = .init(),
        permissionRequester: NotificationPermissionRequesterSpy = .init(),
        now: Date = .mockNow,
        router: EventsRouterSpy = .init()
    ) -> EventEditorViewModel {
        .init(
            target: target,
            events: events,
            categories: categories,
            permissionRequester: permissionRequester,
            calendar: .mockGregorianUTC,
            now: { now },
            router: router
        )
    }
}

extension EventsDependencies {
    static func mock(
        events: EventRepositorySpy = .init(),
        categories: CategoryRepositorySpy = .init()
    ) -> EventsDependencies {
        .init(
            events: events,
            categories: categories,
            notificationPermission: NotificationPermissionRequesterSpy(),
            calendar: .mockGregorianUTC,
            now: { .mockNow },
            settings: .init(
                events: events,
                categories: categories,
                importScanner: ImportScannerSpy(),
                importApplier: ImportApplierSpy(),
                notificationPermission: NotificationPermissionRequesterSpy(),
                version: "1.0",
                build: "1"
            )
        )
    }
}

extension HomeContent {
    static func mock(
        events: [CountdownEvent] = [],
        categories: [EventCategory] = [],
        pinnedEventID: UUID? = nil,
        filter: HomeFilter = .init(),
        time: CurrentTime = .mock()
    ) -> HomeContent {
        HomeData(events: events, categories: categories, pinnedEventID: pinnedEventID)
            .content(filter: filter, at: time)
    }
}
