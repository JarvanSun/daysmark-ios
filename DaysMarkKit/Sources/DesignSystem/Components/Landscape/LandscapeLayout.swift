//
//  LandscapeLayout.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics

struct LandscapeLayout {
    let width: CGFloat
    let height: CGFloat
    let pastCount: Int
    let futureCount: Int

    var center: CGFloat { width / 2 }

    var ground: CGFloat { height - groundInset * artScale }

    private var groundInset: CGFloat { 8 }

    var artScale: CGFloat { height / designHeight }

    private var designHeight: CGFloat { 96 }

    var leafSpread: CGFloat { min(width / (leafReferenceWidth * artScale), leafSpreadLimit) }

    private var leafReferenceWidth: CGFloat { 350 }

    private var leafSpreadLimit: CGFloat { 1.4 }

    var todayMarkerSize: CGFloat { todayMarkerDesignSize * artScale }

    private var todayMarkerDesignSize: CGFloat { 8 }

    var pastHillHeight: CGFloat { hillHeight(count: pastCount, isPast: true) }

    var futureHillHeight: CGFloat { hillHeight(count: futureCount, isPast: false) }

    var trees: [Tree] {
        guard width > 0 else { return [] }

        return pastTrees + futureTrees
    }

    private var pastTrees: [Tree] {
        guard pastCount > 0 else { return [] }

        return [tree("autumn", x: width * 0.115, height: 34, isPast: true)]
    }

    private var futureTrees: [Tree] {
        guard futureCount > 0 else { return [] }

        let anchor = width * 0.85

        return [
            tree(
                "future-back",
                x: anchor + 6 * clusterScale,
                height: 34,
                isPast: false,
                isFlipped: true,
                opacity: 0.7
            ),
            tree(
                "future-side",
                x: anchor - 22 * clusterScale,
                height: 27,
                isPast: false,
                opacity: 0.86
            ),
            tree("future-main", x: anchor, height: 46, isPast: false),
        ]
    }

    private var clusterScale: CGFloat {
        min(width / (clusterReferenceWidth * artScale), clusterScaleLimit) * artScale
    }

    private var clusterReferenceWidth: CGFloat { 350 }

    private var clusterScaleLimit: CGFloat { 1.35 }

    func hillHeight(count: Int, isPast: Bool) -> CGFloat {
        guard count > 0 else { return 0 }

        let growth = minimumHillScale + hillGrowth * CGFloat(min(count, hillCap)) / CGFloat(hillCap)

        return (isPast ? pastHillDesignHeight : futureHillDesignHeight) * artScale * growth
    }

    private var minimumHillScale: CGFloat { 0.6 }

    private var hillGrowth: CGFloat { 0.4 }

    private var hillCap: Int { 8 }

    private var pastHillDesignHeight: CGFloat { 24 }

    private var futureHillDesignHeight: CGFloat { 34 }

    func distantHillHeight(foregroundHeight: CGFloat) -> CGFloat {
        guard foregroundHeight > 0 else { return 0 }

        return foregroundHeight * distantHillRatio
    }

    private var distantHillRatio: CGFloat { 0.78 }

    func surfaceFraction(at position: CGFloat, isPast: Bool) -> CGFloat {
        let samples = isPast ? pastSurface : futureSurface
        let scaled = min(max(position, 0), 1) * CGFloat(samples.count - 1)
        let lower = min(Int(scaled), samples.count - 2)
        let fraction = scaled - CGFloat(lower)

        return samples[lower] + (samples[lower + 1] - samples[lower]) * fraction
    }

    private var pastSurface: [CGFloat] {
        [0, 0.70, 1, 0.72, 0.44, 0.25, 0.15, 0.09, 0.04, 0.02, 0]
    }

    private var futureSurface: [CGFloat] {
        [0, 0.04, 0.09, 0.16, 0.25, 0.39, 0.57, 0.82, 1, 0.79, 0.50]
    }

    private func tree(
        _ id: String,
        x: CGFloat,
        height designHeight: CGFloat,
        isPast: Bool,
        isFlipped: Bool = false,
        opacity: Double = 1
    ) -> Tree {
        let position = isPast ? x / center : (x - center) / center
        let count = isPast ? pastCount : futureCount
        let surface =
            surfaceFraction(at: position, isPast: isPast) * hillHeight(count: count, isPast: isPast)

        return Tree(
            id: id,
            x: x,
            baseline: ground - surface + artScale,
            height: designHeight * artScale * treeScale,
            isPast: isPast,
            isFlipped: isFlipped,
            opacity: opacity
        )
    }

    private var treeScale: CGFloat { min(width / (treeReferenceWidth * artScale), 1) }

    private var treeReferenceWidth: CGFloat { 280 }
}

extension LandscapeLayout {
    struct Tree: Identifiable {
        let id: String
        let x: CGFloat
        let baseline: CGFloat
        let height: CGFloat
        let isPast: Bool
        let isFlipped: Bool
        let opacity: Double
    }
}
