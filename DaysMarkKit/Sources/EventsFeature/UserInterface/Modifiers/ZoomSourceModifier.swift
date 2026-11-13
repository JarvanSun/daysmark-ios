//
//  ZoomSourceModifier.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct ZoomSourceModifier: ViewModifier {
    let source: EventZoomSource
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        switch namespace {
        case .some(let namespace): content.matchedTransitionSource(id: source, in: namespace)
        case nil: content
        }
    }
}

extension View {
    func zoomSource(id source: EventZoomSource, in namespace: Namespace.ID?) -> some View {
        modifier(ZoomSourceModifier(source: source, namespace: namespace))
    }
}
