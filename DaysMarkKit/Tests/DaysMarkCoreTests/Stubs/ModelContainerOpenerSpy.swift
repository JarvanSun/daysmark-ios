//
//  ModelContainerOpenerSpy.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftData
import Synchronization
import TestSupport

final class ModelContainerOpenerSpy: Sendable {
    private let container: ModelContainer
    private let remainingFailures: Mutex<Int>
    private let count = Mutex(0)

    var openCount: Int { count.withLock(\.self) }

    init(opening container: ModelContainer, failingFirst failures: Int = 0) {
        self.container = container
        remainingFailures = Mutex(failures)
    }

    func open() throws -> ModelContainer {
        count.withLock { $0 += 1 }

        let fails = remainingFailures.withLock { remaining in
            defer { remaining = max(remaining - 1, 0) }

            return remaining > 0
        }

        guard !fails else { throw MockError() }

        return container
    }
}
