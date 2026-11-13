//
//  EventShareRenderer.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI
import UIKit

struct EventShareRenderer {
    let locale: Locale
    let cardWidth: CGFloat

    func render(_ content: EventShareContent) -> RenderedEventShareCard? {
        let renderer = ImageRenderer(
            content: EventShareCard(content: content)
                .environment(\.locale, locale)
                .frame(width: cardWidth)
                .fixedSize(horizontal: false, vertical: true)
        )
        renderer.scale = scale
        renderer.isOpaque = true

        guard let image = renderer.uiImage, let data = image.pngData() else { return nil }

        return RenderedEventShareCard(image: image, transferable: SharedEventCard(pngData: data))
    }

    private var scale: CGFloat { 3 }
}
