//
//  WidgetReloaderSpy.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Synchronization

nonisolated public final class WidgetReloaderSpy: WidgetReloading {
    public var reloadCount: Int { reloads.withLock(\.self) }

    private let reloads = Mutex(0)
    private let onReload: @Sendable () -> Void

    public init(onReload: @escaping @Sendable () -> Void = {}) {
        self.onReload = onReload
    }

    public func reloadAll() {
        reloads.withLock { $0 += 1 }
        onReload()
    }
}
