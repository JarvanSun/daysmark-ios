//
//  NotificationRequestDelegate.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/09/03.
//

import DaysMarkCore
import UIKit
import UserNotifications

final class NotificationRequestDelegate: NSObject, UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{
    let requests = AppRequestInbox()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let link = userInfo[NotificationPayloadKey.deepLink.rawValue] as? String

        if let request = link.flatMap(URL.init(string:)).flatMap(AppRequest.init(url:)) {
            Task { @MainActor in requests.hold(request) }
        }

        completionHandler()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
