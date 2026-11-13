//
//  EventsDependencies.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import SettingsFeature

public struct EventsDependencies {
    let events: EventRepository
    let categories: CategoryRepository
    let notificationPermission: NotificationPermissionRequesting
    let calendar: Calendar
    let now: () -> Date
    let settings: SettingsDependencies

    public init(
        events: EventRepository,
        categories: CategoryRepository,
        notificationPermission: NotificationPermissionRequesting,
        calendar: Calendar,
        now: @escaping () -> Date,
        settings: SettingsDependencies
    ) {
        self.events = events
        self.categories = categories
        self.notificationPermission = notificationPermission
        self.calendar = calendar
        self.now = now
        self.settings = settings
    }

    func makeHomeViewModel(router: EventsRouting) -> HomeViewModel {
        HomeViewModel(events: events, categories: categories, time: CurrentTime(), router: router)
    }

    func makeDetailViewModel(
        eventID: CountdownEvent.ID,
        router: EventsRouting
    ) -> EventDetailViewModel {
        EventDetailViewModel(eventID: eventID, events: events, time: CurrentTime(), router: router)
    }

    func makeEditorViewModel(
        target: EditorTarget,
        router: EventsRouting
    ) -> EventEditorViewModel {
        EventEditorViewModel(
            target: target,
            events: events,
            categories: categories,
            permissionRequester: notificationPermission,
            calendar: calendar,
            now: now,
            router: router
        )
    }

    func makeShareViewModel(
        eventID: CountdownEvent.ID,
        router: EventsRouting
    ) -> EventShareViewModel {
        EventShareViewModel(
            eventID: eventID,
            events: events,
            categories: categories,
            time: CurrentTime(),
            router: router
        )
    }
}
