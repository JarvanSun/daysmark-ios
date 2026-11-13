//
//  SystemSurfaceRefresherSpy.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

public final class SystemSurfaceRefresherSpy: SystemSurfaceRefreshing {
    public private(set) var refreshCount = 0

    public init() {}

    public func refresh() {
        refreshCount += 1
    }
}
