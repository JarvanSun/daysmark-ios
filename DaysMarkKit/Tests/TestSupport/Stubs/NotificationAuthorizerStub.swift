//
//  NotificationAuthorizerStub.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Synchronization

nonisolated public final class NotificationAuthorizerStub: NotificationAuthorizing {
    public var requestCount: Int { state.withLock(\.requestCount) }

    private struct State {
        var permission: NotificationPermission
        var requestCount = 0
    }

    private let state: Mutex<State>
    private let grants: Bool
    private let error: Error?

    public init(permission: NotificationPermission, grants: Bool = true, error: Error? = nil) {
        state = Mutex(State(permission: permission))
        self.grants = grants
        self.error = error
    }

    public func currentPermission() async -> NotificationPermission {
        state.withLock(\.permission)
    }

    public func requestAuthorization() async throws -> Bool {
        state.withLock { $0.requestCount += 1 }

        if let error {
            throw error
        }

        state.withLock { $0.permission = grants ? .authorized : .denied }
        return grants
    }
}
