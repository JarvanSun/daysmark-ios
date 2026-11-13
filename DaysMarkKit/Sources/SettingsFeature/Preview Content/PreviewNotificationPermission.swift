//
//  PreviewNotificationPermission.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore

struct PreviewNotificationPermission: NotificationPermissionRequesting {
    let permission: NotificationPermission

    func currentPermission() async -> NotificationPermission {
        permission
    }

    @discardableResult
    func requestIfNeeded() async -> NotificationPermission {
        .authorized
    }
}
#endif
