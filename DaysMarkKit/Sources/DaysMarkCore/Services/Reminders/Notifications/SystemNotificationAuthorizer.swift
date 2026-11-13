//
//  SystemNotificationAuthorizer.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import UserNotifications

public protocol NotificationAuthorizing: Sendable {
    func currentPermission() async -> NotificationPermission
    func requestAuthorization() async throws -> Bool
}

public struct SystemNotificationAuthorizer: NotificationAuthorizing {
    public init() {}

    public func currentPermission() async -> NotificationPermission {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .notDetermined: .notDetermined
        case .denied: .denied
        case .authorized, .provisional, .ephemeral: .authorized
        @unknown default: .denied
        }
    }

    public func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
    }
}
