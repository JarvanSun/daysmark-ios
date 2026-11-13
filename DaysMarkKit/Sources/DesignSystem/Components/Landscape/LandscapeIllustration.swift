//
//  LandscapeIllustration.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/09/05.
//

import SunUserInterface
import SwiftUI

public struct LandscapeIllustration: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.colorScheme) private var colorScheme

    private let markers: [LandscapeMarker]

    public init(markers: [LandscapeMarker]) {
        self.markers = markers
    }

    public var body: some View {
        GeometryReader { proxy in
            landscape(in: layout(width: proxy.size.width))
        }
        .frame(height: dimensions.landscapeHeight)
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text("landscape.accessibility \(pastCount) \(futureCount)", bundle: .module)
        )
    }

    private func layout(width: CGFloat) -> LandscapeLayout {
        LandscapeLayout(
            width: width,
            height: dimensions.landscapeHeight,
            pastCount: pastCount,
            futureCount: futureCount
        )
    }

    private func landscape(in layout: LandscapeLayout) -> some View {
        let trees = layout.trees

        return ZStack(alignment: .bottomLeading) {
            distantHill(in: layout)

            ForEach(trees) { tree in
                treeImage(isPast: tree.isPast, height: tree.height)
                    .scaleEffect(x: tree.isFlipped ? -1 : 1, y: 1)
                    .opacity(tree.opacity)
                    .position(x: tree.x, y: tree.baseline - tree.height / 2)
            }

            hills(in: layout)

            leaves(around: trees.first(where: \.isPast), in: layout)

            Divider()
                .frame(width: layout.width)
                .position(x: layout.center, y: layout.ground)

            Circle()
                .fill(DaysMarkColor.tint.color)
                .frame(width: layout.todayMarkerSize, height: layout.todayMarkerSize)
                .position(x: layout.center, y: layout.ground)
        }
        .frame(width: layout.width, height: layout.height)
    }

    @ViewBuilder
    private func distantHill(in layout: LandscapeLayout) -> some View {
        if layout.futureHillHeight > 0 {
            let height = layout.distantHillHeight(foregroundHeight: layout.futureHillHeight)

            CroppedArtwork(
                artwork: .distantSlope,
                width: layout.center * distantHillWidthRatio,
                visibleHeight: height
            )
            .saturation(0.4)
            .contrast(0.84)
            .colorMultiply(DaysMarkColor.landscapeFutureGround.color)
            .opacity(colorScheme == .dark ? 0.75 : 0.55)
            .position(x: layout.center * distantHillPositionRatio, y: layout.ground - height / 2)
        }
    }

    private var distantHillWidthRatio: CGFloat { 0.82 }

    private var distantHillPositionRatio: CGFloat { 1.49 }

    private func treeImage(isPast: Bool, height: CGFloat) -> some View {
        let artwork: LandscapeArtwork = isPast ? .autumnTree : .futureTree
        let foliage: DaysMarkColor = isPast ? .landscapePastFoliage : .landscapeFutureFoliage

        return Image(style: artwork)
            .resizable()
            .frame(width: artwork.width(atHeight: height), height: height)
            .frame(width: artwork.visibleWidth(atHeight: height), alignment: .leading)
            .clipped()
            .saturation(0.55)
            .contrast(0.94)
            .colorMultiply(foliage.color)
    }

    @ViewBuilder
    private func hills(in layout: LandscapeLayout) -> some View {
        if layout.pastHillHeight > 0 {
            hill(isPast: true, width: layout.center, height: layout.pastHillHeight)
                .position(x: layout.center / 2, y: layout.ground - layout.pastHillHeight / 2)
        }

        if layout.futureHillHeight > 0 {
            hill(isPast: false, width: layout.center, height: layout.futureHillHeight)
                .position(
                    x: layout.width - layout.center / 2,
                    y: layout.ground - layout.futureHillHeight / 2
                )
        }
    }

    private func hill(isPast: Bool, width: CGFloat, height: CGFloat) -> some View {
        let artwork: LandscapeArtwork = isPast ? .pastHill : .futureHill
        let ground: DaysMarkColor = isPast ? .landscapePastGround : .landscapeFutureGround

        return CroppedArtwork(artwork: artwork, width: width, visibleHeight: height)
            .saturation(0.5)
            .contrast(0.86)
            .colorMultiply(ground.color)
            .clipShape(HillEnding(isPast: isPast))
    }

    @ViewBuilder
    private func leaves(around autumn: LandscapeLayout.Tree?, in layout: LandscapeLayout)
        -> some View
    {
        if let autumn {
            ForEach(LandscapeLeaf.allCases) { leaf in
                Image(style: LandscapeArtwork.autumnLeaf)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .saturation(0.55)
                    .colorMultiply(DaysMarkColor.landscapePastFoliage.color)
                    .frame(width: leaf.size * layout.artScale)
                    .rotationEffect(.degrees(leaf.rotation))
                    .opacity(leaf.opacity)
                    .position(
                        x: autumn.x + leaf.offset.x * layout.artScale * layout.leafSpread,
                        y: autumn.baseline - autumn.height + leaf.offset.y * layout.artScale
                    )
            }
        }
    }

    private var pastCount: Int { markers.filter(\.isPast).count }

    private var futureCount: Int { markers.count - pastCount }
}

// MARK: - Previews

#if DEBUG
#Preview("Landscape · 3 past, 5 future") {
    LandscapeIllustration(markers: PreviewObjectPool().landscapeMarkers)
        .padding()
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
