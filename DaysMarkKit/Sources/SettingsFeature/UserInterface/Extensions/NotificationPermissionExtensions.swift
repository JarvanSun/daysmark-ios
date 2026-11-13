//
//  NotificationPermissionExtensions.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

extension NotificationPermission {
    var title: LocalizedStringResource {
        switch self {
        case .notDetermined:
            LocalizedStringResource(
                "settings.notifications.permission.notDetermined",
                bundle: .module
            )
        case .authorized:
            LocalizedStringResource("settings.notifications.permission.allowed", bundle: .module)
        case .denied:
            LocalizedStringResource("settings.notifications.permission.denied", bundle: .module)
        }
    }
}
