//
//  WidgetContentReaderExtensions.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

extension WidgetContentReader {
    init() {
        self.init(storage: .appGroup, timeZone: { .current }, locale: { .current })
    }

    nonisolated func placeholder(for request: WidgetContentRequest) -> WidgetContent {
        placeholder(titled: String(localized: "widget.placeholder.title"), for: request)
    }
}
