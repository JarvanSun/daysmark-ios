//
//  LandscapeArtwork.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SunUserInterface
import SwiftUI

enum LandscapeArtwork: String, ImageStyling {
    case pastHill = "LandscapePastHill"
    case futureHill = "LandscapeFutureHill"
    case distantSlope = "LandscapeDistantSlope"
    case autumnTree = "LandscapeAutumnTree"
    case futureTree = "LandscapeFutureTree"
    case autumnLeaf = "LandscapeAutumnLeaf"

    var definingBundle: Bundle { .module }

    func width(atHeight height: CGFloat) -> CGFloat {
        height * source.width / source.height
    }

    func visibleWidth(atHeight height: CGFloat) -> CGFloat {
        height * source.visibleWidth / source.height
    }

    func fullHeight(forVisibleHeight height: CGFloat) -> CGFloat {
        height * source.height / crop.span
    }

    func cropOffset(forVisibleHeight height: CGFloat) -> CGFloat {
        -height * crop.top / crop.span
    }

    private var source: (width: CGFloat, visibleWidth: CGFloat, height: CGFloat) {
        switch self {
        case .pastHill: (0, 0, 323)
        case .futureHill: (0, 0, 394)
        case .distantSlope: (0, 0, 724)
        case .autumnTree: (186, 186, 261)
        case .futureTree: (132, 84, 363)
        case .autumnLeaf: (0, 0, 0)
        }
    }

    private var crop: (top: CGFloat, span: CGFloat) {
        switch self {
        case .pastHill: (87, 200 - 87)
        case .futureHill: (143, 322 - 143)
        default: (326, 222)
        }
    }
}

struct CroppedArtwork: View {
    let artwork: LandscapeArtwork
    let width: CGFloat
    let visibleHeight: CGFloat

    var body: some View {
        Image(style: artwork)
            .resizable()
            .frame(width: width, height: artwork.fullHeight(forVisibleHeight: visibleHeight))
            .offset(y: artwork.cropOffset(forVisibleHeight: visibleHeight))
            .frame(width: width, height: visibleHeight, alignment: .top)
            .clipped()
    }
}
