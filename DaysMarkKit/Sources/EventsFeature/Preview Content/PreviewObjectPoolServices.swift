//
//  PreviewObjectPoolServices.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

#if DEBUG
import DaysMarkCore
import Foundation

final class PreviewEventsRouter: EventsRouting {
    var isPresentingSheet: Bool { false }

    func showHome() {}

    func showDetail(for id: CountdownEvent.ID) {}

    func showDetailFromFocus(for id: CountdownEvent.ID) {}

    func showSettings(_ page: SettingsPage) {}

    func showEditor(for target: EditorTarget) {}

    func showSpecialNodes() {}

    func showSharing(for id: CountdownEvent.ID) {}

    func showRequestedDetail(for id: CountdownEvent.ID) {}

    func showRequestedSettings(_ page: SettingsPage) {}

    func closeDetail(for id: CountdownEvent.ID) {}

    func dismissSheet() {}
}

struct PreviewNotificationPermission: NotificationPermissionRequesting {
    func currentPermission() async -> NotificationPermission {
        .authorized
    }

    @discardableResult
    func requestIfNeeded() async -> NotificationPermission {
        .authorized
    }
}

struct PreviewSystemSurfaceRefresher: SystemSurfaceRefreshing {
    func refresh() {}
}
#endif
