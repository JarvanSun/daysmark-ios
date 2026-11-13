//
//  DaysMarkFontTests.swift
//  DesignSystemTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import Testing

@testable import DesignSystem

struct DaysMarkFontTests {
    @Test(arguments: DaysMarkFont.allCases)
    func scalesWithDynamicType(font: DaysMarkFont) {
        #expect(font.size > 0)
        #expect(font.lineHeight == font.nativeLineHeight)
    }

    @Test
    func detailNumberScalesFromItsDesignSize() {
        #expect(DaysMarkFont.detailNumber.size == 104)
        #expect(DaysMarkFont.detailNumber.font(scaledBy: 1) == DaysMarkFont.detailNumber.font)
    }
}
