//
//  SettingsDestinationViewTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SunUserInterface
import Testing

@testable import SettingsFeature

struct SettingsDestinationViewTests {
    @Test(arguments: [
        (SettingsDestination.root, PresentingStyle.push),
        (.notifications, .push),
        (.categories, .push),
        (.importDates, .push),
        (.widgets, .push),
        (.siriAndShortcuts, .push),
        (.recentlyDeleted(highlighting: nil), .push),
        (.categoryEditor(.new), .sheet),
    ])
    func styleThenPushesScreensAndPresentsEditorsAsSheets(
        destination: SettingsDestination,
        expected: PresentingStyle
    ) {
        // Given
        let router = SettingsRouter(dependencies: .mock())

        // When
        let view = router.view(for: destination)

        // Then
        #expect(view.style == expected)
    }
}
