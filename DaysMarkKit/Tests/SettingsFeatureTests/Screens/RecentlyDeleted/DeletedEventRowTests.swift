//
//  DeletedEventRowTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import Foundation
import SwiftUI
import Testing

@testable import SettingsFeature

struct DeletedEventRowTests {
    @Test(arguments: [(true, DaysMarkColor.tintSoft.color), (false, Color.clear)])
    func backgroundThenMarksTheHighlightedEvent(isHighlighted: Bool, expected: Color) {
        // Given / When
        let row = RecentlyDeletedContent.Row(
            id: UUID(),
            title: "Trip",
            deletedAt: .mockNow,
            isHighlighted: isHighlighted
        )

        // Then
        #expect(row.background == expected)
    }
}
