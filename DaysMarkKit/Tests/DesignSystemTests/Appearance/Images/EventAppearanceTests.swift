//
//  EventAppearanceTests.swift
//  DesignSystemTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing
import UIKit

@testable import DesignSystem

struct EventAppearanceTests {
    @Test(arguments: EventAppearance.allCases)
    func hasBundledArtwork(appearance: EventAppearance) throws {
        let image = try #require(UIImage(named: appearance.name, in: .module, compatibleWith: nil))
        let cgImage = try #require(image.cgImage)
        let alphaFormats: [CGImageAlphaInfo] = [
            .first, .last, .premultipliedFirst, .premultipliedLast,
        ]

        #expect(image.size.width > 0 && image.size.height > 0)
        #expect(alphaFormats.contains(cgImage.alphaInfo))
        #expect(UIImage(systemName: appearance.symbol.rawValue) != nil)
    }

    @Test
    func selectableAppearancesHaveDistinctArtworkAndNames() {
        let selectable = EventAppearance.allCases.filter(\.isSelectable)

        #expect(selectable.count == 10)
        #expect(Set(selectable.map(\.name)).count == selectable.count)
        #expect(selectable.allSatisfy { $0.label != nil })
    }

    @Test
    func unknownAndEmptyKeysFallBackToTheCalendar() {
        for key in ["", "calendar", "unknown.old.symbol"] {
            #expect(EventAppearance(storedKey: key) == .calendar)
        }

        #expect(EventAppearance(storedKey: "birthday.cake") == .birthdayCake)
    }
}
