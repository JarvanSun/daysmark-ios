//
//  EventsDestinationViewTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import SunUserInterface
import Testing

@testable import EventsFeature

struct EventsDestinationViewTests {
    @Test(arguments: [
        (EventsDestination.root, PresentingStyle.push),
        (.detail(.mockActive, fromFocus: false), .push),
        (.settings(.root), .push),
        (.specialNodes, .push),
        (.editor(.existing(.mockActive)), .sheet),
        (.editor(.new(categoryID: BuiltInCategory.important.id)), .sheet),
        (.sharing(.mockActive), .sheet),
    ])
    func styleThenPushesScreensAndPresentsEditorAndSharingAsSheets(
        destination: EventsDestination,
        expected: PresentingStyle
    ) {
        // Given
        let router = EventsRouter(dependencies: .mock())

        // When
        let view = router.view(for: destination)

        // Then
        #expect(view.style == expected)
    }
}
