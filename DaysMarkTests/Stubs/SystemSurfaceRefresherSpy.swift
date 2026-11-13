//
//  SystemSurfaceRefresherSpy.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

final class SystemSurfaceRefresherSpy: SystemSurfaceRefreshing {
    private(set) var refreshCount = 0

    func refresh() {
        refreshCount += 1
    }
}
