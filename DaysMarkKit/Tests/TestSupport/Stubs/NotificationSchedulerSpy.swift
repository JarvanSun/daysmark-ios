//
//  NotificationSchedulerSpy.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Synchronization

nonisolated public final class NotificationSchedulerSpy: NotificationScheduling {
    public var added: [ScheduledReminder] { state.withLock(\.added) }
    public var removed: [String] { state.withLock(\.removed) }
    public var categoryRegistrations: Int { state.withLock(\.categoryRegistrations) }
    public var passes: Int { state.withLock(\.passes) }
    public var mostConcurrentPasses: Int { state.withLock(\.mostConcurrentPasses) }

    private struct State {
        var pending: Set<String>
        var added: [ScheduledReminder] = []
        var removed: [String] = []
        var categoryRegistrations = 0
        var passes = 0
        var activePasses = 0
        var mostConcurrentPasses = 0
    }

    private let state: Mutex<State>
    private let failure: Error?
    private let onPass: @Sendable () -> Void

    public init(
        pending: Set<String> = [],
        failure: Error? = nil,
        onPass: @escaping @Sendable () -> Void = {}
    ) {
        state = Mutex(State(pending: pending))
        self.failure = failure
        self.onPass = onPass
    }

    public func registerCategories() async {
        state.withLock { $0.categoryRegistrations += 1 }
    }

    public func pendingIdentifiers() async -> Set<String> {
        state.withLock {
            $0.passes += 1
            $0.activePasses += 1
            $0.mostConcurrentPasses = max($0.mostConcurrentPasses, $0.activePasses)
        }
        onPass()

        for _ in 0..<8 {
            await Task.yield()
        }

        return state.withLock {
            $0.activePasses -= 1
            return $0.pending
        }
    }

    public func add(_ reminder: ScheduledReminder) async throws {
        if let failure {
            throw failure
        }

        state.withLock { $0.added.append(reminder) }
        await Task.yield()
    }

    public func removePending(identifiers: [String]) async {
        state.withLock { $0.removed.append(contentsOf: identifiers) }
    }
}
