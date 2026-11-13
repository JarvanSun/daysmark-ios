//
//  PreviewNotificationPermission.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore

struct PreviewNotificationPermission: NotificationPermissionRequesting {
    func currentPermission() async -> NotificationPermission {
        .authorized
    }

    @discardableResult
    func requestIfNeeded() async -> NotificationPermission {
        .authorized
    }
}
#endif
