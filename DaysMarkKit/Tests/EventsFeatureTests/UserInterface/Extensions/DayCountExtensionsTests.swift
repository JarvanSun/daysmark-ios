//
//  DayCountExtensionsTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import DesignSystem
import Testing

@testable import EventsFeature

struct DayCountExtensionsTests {
    @Test func tintWhenPastThenUsesThePastColor() {
        // Given / When / Then
        #expect(DayCount.Direction.past.tint == .past)
        #expect(DayCount.Direction.today.tint == .upcoming)
        #expect(DayCount.Direction.upcoming.tint == .upcoming)
    }

    @Test func landscapeMarkerWhenTodayThenIsNil() {
        // Given
        let counts = [
            DayCount(days: 0, direction: .today),
            DayCount(days: 3, direction: .past),
            DayCount(days: 5, direction: .upcoming),
        ]

        // When
        let markers = counts.compactMap(\.landscapeMarker)

        // Then
        #expect(
            markers == [
                LandscapeMarker(days: 3, isPast: true), LandscapeMarker(days: 5, isPast: false),
            ]
        )
    }
}
