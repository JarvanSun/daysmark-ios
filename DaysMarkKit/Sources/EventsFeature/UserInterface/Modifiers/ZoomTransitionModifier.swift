//
//  ZoomTransitionModifier.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

struct ZoomTransitionModifier: ViewModifier {
    let source: EventZoomSource
    let namespace: Namespace.ID?

    func body(content: Content) -> some View {
        switch namespace {
        case .some(let namespace):
            content.navigationTransition(.zoom(sourceID: source, in: namespace))
        case nil: content
        }
    }
}

extension View {
    func zoomTransition(from source: EventZoomSource, in namespace: Namespace.ID?) -> some View {
        modifier(ZoomTransitionModifier(source: source, namespace: namespace))
    }
}
