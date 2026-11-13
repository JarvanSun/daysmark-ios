//
//  SystemNotificationScheduler.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import UserNotifications

public protocol NotificationScheduling: Sendable {
    func registerCategories() async
    func pendingIdentifiers() async -> Set<String>
    func add(_ reminder: ScheduledReminder) async throws
    func removePending(identifiers: [String]) async
}

public struct SystemNotificationScheduler: NotificationScheduling {
    public init() {}

    public func registerCategories() async {
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([
            UNNotificationCategory(
                identifier: NotificationCategoryIdentifier.reminder.rawValue,
                actions: [],
                intentIdentifiers: [],
                options: []
            )
        ])

        try? await center.setBadgeCount(0)
    }

    public func pendingIdentifiers() async -> Set<String> {
        Set(
            await UNUserNotificationCenter.current().pendingNotificationRequests().map(\.identifier)
        )
    }

    public func add(_ reminder: ScheduledReminder) async throws {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.userInfo = reminder.userInfo
        content.sound = .default
        content.categoryIdentifier = NotificationCategoryIdentifier.reminder.rawValue

        try await UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: reminder.identifier,
                content: content,
                trigger: UNCalendarNotificationTrigger(
                    dateMatching: reminder.dateComponents,
                    repeats: false
                )
            )
        )
    }

    public func removePending(identifiers: [String]) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

public struct ScheduledReminder: Equatable, Sendable {
    public let identifier: String
    public let title: String
    public let body: String
    public let userInfo: [String: String]
    public let dateComponents: DateComponents
}

enum NotificationCategoryIdentifier: String {
    case reminder = "countdownReminder"
}
