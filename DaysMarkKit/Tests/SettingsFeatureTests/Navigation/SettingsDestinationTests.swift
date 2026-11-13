//
//  SettingsDestinationTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import SunUserInterface
import Testing

@testable import SettingsFeature

struct SettingsDestinationTests {
    @Test func initWithTheRootPageThenIsTheRoot() {
        #expect(SettingsDestination(.root).isRoot)
    }

    @Test func initWithTheWidgetsPageThenIsTheWidgetInstructions() {
        #expect(SettingsDestination(.widgets) == .widgets)
    }

    @Test func initWithRecentlyDeletedThenKeepsTheHighlightedEvent() {
        // Given
        let eventID = UUID()

        // When
        let destination = SettingsDestination(.recentlyDeleted(highlighting: eventID))

        // Then
        #expect(destination == .recentlyDeleted(highlighting: eventID))
    }
}
