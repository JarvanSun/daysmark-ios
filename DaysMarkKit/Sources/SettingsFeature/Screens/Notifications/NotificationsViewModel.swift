//
//  NotificationsViewModel.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class NotificationsViewModel {
    private(set) var permission: NotificationPermission = .notDetermined
    private(set) var activity: NotificationsActivity = .idle
    private(set) var permissionRequest: UUID?

    private let permissionRequester: NotificationPermissionRequesting

    init(permissionRequester: NotificationPermissionRequesting) {
        self.permissionRequester = permissionRequester
    }

    func refresh() async {
        let current = await permissionRequester.currentPermission()
        guard !Task.isCancelled else { return }

        permission = current
    }

    func enableNotifications() {
        guard activity == .idle else { return }

        activity = .requestingPermission
        permissionRequest = UUID()
    }

    func requestPermission() async {
        guard permissionRequest != nil else { return }

        let granted = await permissionRequester.requestIfNeeded()
        guard !Task.isCancelled else { return }

        permission = granted
        activity = .idle
    }
}
