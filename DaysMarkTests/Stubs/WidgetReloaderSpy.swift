//
//  WidgetReloaderSpy.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Synchronization

final class WidgetReloaderSpy: WidgetReloading {
    var reloadCount: Int { reloads.withLock(\.self) }

    private let reloads = Mutex(0)

    func reloadAll() {
        reloads.withLock { $0 += 1 }
    }
}
