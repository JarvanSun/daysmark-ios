//
//  DimensionStylingExtensionsTests.swift
//  DesignSystemTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import SunUserInterface
import Testing

@testable import DesignSystem

struct DimensionStylingExtensionsTests {
    @Test
    func defaultsKeepTheirValues() {
        let dimensions = DimensionStyle()

        #expect(dimensions.pageMargin == 20)
        #expect(dimensions.spaceCompact == 4)
        #expect(dimensions.minimumTapTarget == 44)
        #expect(dimensions.rowMinimumHeight == 52)
        #expect(dimensions.rowLineSpacing == 2)
        #expect(dimensions.iconColumnWidth == 28)
        #expect(dimensions.eventIconColumnWidth == 36)
        #expect(dimensions.landscapeHeight == 96)
        #expect(dimensions.settingsSeparatorInset == 40)
    }

    @Test
    func overridesReplaceDefaults() {
        let dimensions = DimensionStyle(
            tokens: DimensionTokens(tokens: [
                "pageMargin": 16, "iconColumnWidth": 30, "spaceMedium": 10,
            ])
        )

        #expect(dimensions.pageMargin == 16)
        #expect(dimensions.settingsSeparatorInset == 40)
    }
}
