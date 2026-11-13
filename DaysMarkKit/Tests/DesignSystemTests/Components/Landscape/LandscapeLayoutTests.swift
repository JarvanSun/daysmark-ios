//
//  LandscapeLayoutTests.swift
//  DesignSystemTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DesignSystem

struct LandscapeLayoutTests {
    @Test("Distant hills preserve empty sides and stay within the landscape canvas")
    func distantHillsAreDecorativeAndBounded() {
        let layout = layout(width: 350, pastCount: 0, futureCount: 0)

        #expect(layout.distantHillHeight(foregroundHeight: 0) == 0)

        for past in [true, false] {
            for count in 1...20 {
                let foreground = layout.hillHeight(count: count, isPast: past)
                let distant = layout.distantHillHeight(foregroundHeight: foreground)

                #expect(distant > 0 && distant < foreground)
                #expect(distant < 48)
            }
        }
    }

    @Test("Landscape stays a small composed grove instead of one tree per event")
    func landscapeGroveIsStableAndBounded() {
        for width: CGFloat in [160, 280, 350, 760] {
            let sparse = layout(width: width, pastCount: 1, futureCount: 1).trees
            let dense = layout(width: width, pastCount: 100, futureCount: 100).trees
            let future = sparse.filter { !$0.isPast }

            #expect(sparse.map(\.id) == dense.map(\.id))
            #expect(sparse.count == 4)
            #expect(sparse.filter(\.isPast).count == 1)
            #expect(Set(future.map(\.height)).count == 3)

            for tree in dense {
                #expect(tree.x > 0 && tree.x < width)
                #expect(tree.baseline - tree.height >= 0)
                #expect(tree.baseline <= 89)
            }
        }

        #expect(layout(width: 350, pastCount: 0, futureCount: 0).trees.isEmpty)
        #expect(layout(width: 350, pastCount: 0, futureCount: 5).trees.allSatisfy { !$0.isPast })
    }

    @Test("Landscape hills grow monotonically and preserve asymmetric caps")
    func landscapeHillGrowthIsBounded() {
        let layout = layout(width: 350, pastCount: 0, futureCount: 0)

        for past in [true, false] {
            let heights = (0...20).map { layout.hillHeight(count: $0, isPast: past) }

            #expect(heights[0] == 0)
            #expect(heights == heights.sorted())
            #expect(heights[8] == heights[20])
        }

        #expect(layout.hillHeight(count: 8, isPast: true) == 24)
        #expect(layout.hillHeight(count: 8, isPast: false) == 34)
    }

    @Test("Landscape tree anchors follow the visible PNG crest and flatten toward today")
    func landscapeAnchorsMatchAssets() {
        let layout = layout(width: 350, pastCount: 0, futureCount: 0)

        #expect(layout.surfaceFraction(at: 0.2, isPast: true) == 1)
        #expect(layout.surfaceFraction(at: 0.8, isPast: false) == 1)
        #expect(layout.surfaceFraction(at: 1, isPast: true) == 0)
        #expect(layout.surfaceFraction(at: 0, isPast: false) == 0)

        for past in [false, true] {
            for step in -10...110 {
                let height = layout.surfaceFraction(at: CGFloat(step) / 100, isPast: past)

                #expect((0...1).contains(height))
            }
        }
    }

    private func layout(width: CGFloat, pastCount: Int, futureCount: Int) -> LandscapeLayout {
        LandscapeLayout(width: width, height: 96, pastCount: pastCount, futureCount: futureCount)
    }
}
