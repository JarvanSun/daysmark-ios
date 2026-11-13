//
//  SettingsDependencies.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

public struct SettingsDependencies {
    let events: EventRepository
    let categories: CategoryRepository
    let importScanner: ImportScanning
    let importApplier: ImportApplying
    let notificationPermission: NotificationPermissionRequesting
    let version: String
    let build: String

    public init(
        events: EventRepository,
        categories: CategoryRepository,
        importScanner: ImportScanning,
        importApplier: ImportApplying,
        notificationPermission: NotificationPermissionRequesting,
        version: String,
        build: String
    ) {
        self.events = events
        self.categories = categories
        self.importScanner = importScanner
        self.importApplier = importApplier
        self.notificationPermission = notificationPermission
        self.version = version
        self.build = build
    }
}
