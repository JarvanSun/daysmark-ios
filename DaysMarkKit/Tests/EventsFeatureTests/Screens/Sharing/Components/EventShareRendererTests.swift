//
//  EventShareRendererTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation
import Testing
import UIKit

@testable import EventsFeature

struct EventShareRendererTests {
    @Test func renderThenExportsAnOpaquePNGThatGrowsForLongTitles() throws {
        // Given
        let renderer = EventShareRenderer(locale: Locale(identifier: "de_DE"), cardWidth: 360)
        let short = makeContent(title: "Mia 的生日")
        let long = makeContent(
            title: "Unser erster gemeinsamer Tag in unserem neuen Zuhause am Hafen"
        )

        // When
        let shortCard = try #require(renderer.render(short))
        let longCard = try #require(renderer.render(long))
        let decoded = try #require(UIImage(data: shortCard.transferable.pngData))

        // Then
        #expect(decoded.cgImage?.width == 1_080)
        #expect(decoded.cgImage?.height == shortCard.image.cgImage?.height)
        #expect(longCard.image.size.height > shortCard.image.size.height)
        #expect(
            shortCard.transferable.pngData.prefix(8) == Data([137, 80, 78, 71, 13, 10, 26, 10])
        )
    }

    private func makeContent(title: String) -> EventShareContent {
        EventShareContent(
            title: title,
            relativeTime: "in 18 days",
            absoluteTime: "September 23, 2026",
            calendarName: nil,
            referenceDateText: "As of Sep 5, 2026",
            appearance: EventAppearance(storedKey: "birthday.cake"),
            direction: .upcoming,
            category: nil
        )
    }
}
