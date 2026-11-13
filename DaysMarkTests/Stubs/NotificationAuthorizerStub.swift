//
//  NotificationAuthorizerStub.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

struct NotificationAuthorizerStub: NotificationAuthorizing {
    func currentPermission() async -> NotificationPermission {
        .authorized
    }

    func requestAuthorization() async throws -> Bool {
        true
    }
}
