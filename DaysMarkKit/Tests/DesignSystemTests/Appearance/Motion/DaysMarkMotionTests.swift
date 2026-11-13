//
//  DaysMarkMotionTests.swift
//  DesignSystemTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI
import Testing

@testable import DesignSystem

struct DaysMarkMotionTests {
    @Test
    func namedTimingsKeepTheirCurves() {
        #expect(DaysMarkMotion.focusChange.animation == .smooth(duration: 0.38))
        #expect(DaysMarkMotion.dayChange.animation == .smooth(duration: 0.45))
        #expect(DaysMarkMotion.unitChange.animation == .smooth(duration: 0.5))
        #expect(DaysMarkMotion.directionChange.animation == .smooth(duration: 0.6))
        #expect(DaysMarkMotion.countChange.animation == .smooth(duration: 0.6))
    }

    @Test
    func reduceMotionRemovesTheAnimation() {
        #expect(DaysMarkMotion.focusChange.animation(reducingMotion: true) == nil)
        #expect(DaysMarkMotion.focusChange.animation(reducingMotion: false) != nil)
    }
}
