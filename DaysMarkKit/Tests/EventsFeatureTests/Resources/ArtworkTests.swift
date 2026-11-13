//
//  ArtworkTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing
import UIKit

@testable import EventsFeature

struct ArtworkTests {
    @Test func filteredEmptyArtworkThenIsBundledWithThePackage() throws {
        // Given / When
        let image = try #require(
            UIImage(named: "HomeEmptyPaperLeaves", in: .module, compatibleWith: nil)
        )

        // Then
        #expect(image.size.width > image.size.height)
    }

    @Test(arguments: ["HomeFirstDate", "HomeFirstDateDark", "ShareBotanical"])
    func artworkThenIsBundledWithThePackage(name: String) {
        #expect(UIImage(named: name, in: .module, compatibleWith: nil) != nil)
    }
}
