//
//  LoggerExtensions.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/25.
//

import OSLog

extension Logger {
    public init(category: LogCategory) {
        self.init(
            subsystem: Bundle.main.bundleIdentifier ?? "com.example.daysmark",
            category: category.rawValue
        )
    }
}
