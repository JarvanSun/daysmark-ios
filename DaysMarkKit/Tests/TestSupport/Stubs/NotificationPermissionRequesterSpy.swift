//
//  NotificationPermissionRequesterSpy.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Synchronization

nonisolated public final class NotificationPermissionRequesterSpy:
    NotificationPermissionRequesting
{
    public var requestCount: Int { requests.withLock(\.self) }

    private let current: NotificationPermission
    private let granted: NotificationPermission
    private let requests = Mutex(0)

    public init(
        current: NotificationPermission = .notDetermined,
        granted: NotificationPermission = .authorized
    ) {
        self.current = current
        self.granted = granted
    }

    public func currentPermission() async -> NotificationPermission {
        current
    }

    @discardableResult
    public func requestIfNeeded() async -> NotificationPermission {
        requests.withLock { $0 += 1 }

        return granted
    }
}
