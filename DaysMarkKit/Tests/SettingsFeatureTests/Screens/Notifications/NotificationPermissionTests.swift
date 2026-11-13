//
//  NotificationPermissionTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import SettingsFeature

struct NotificationPermissionTests {
    @Test(arguments: [
        (NotificationPermission.notDetermined, "settings.notifications.permission.notDetermined"),
        (.authorized, "settings.notifications.permission.allowed"),
        (.denied, "settings.notifications.permission.denied"),
    ])
    func titleThenNamesThePermission(permission: NotificationPermission, key: String) {
        #expect(permission.title.key == key)
    }
}
