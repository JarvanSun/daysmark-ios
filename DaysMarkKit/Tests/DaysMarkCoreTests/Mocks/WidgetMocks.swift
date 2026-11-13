//
//  WidgetMocks.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import WidgetKit

@testable import DaysMarkCore

extension WidgetFamily {
    nonisolated static var mockSupported: [WidgetFamily] {
        [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ]
    }
}

extension WidgetStoreContents {
    static func mock(
        events: [CountdownEvent],
        categories: [EventCategory] = [],
        focus: CountdownEvent.ID? = nil
    ) -> WidgetStoreContents {
        WidgetStoreContents(
            events: events,
            categories: categories,
            focusedEventID: events.first {
                $0.id == focus && $0.deletedAt == nil && $0.permanentDeletionRequestedAt == nil
            }?.id
        )
    }
}
