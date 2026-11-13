//
//  RequestHandlingModifier.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import SwiftUI

struct RequestHandlingModifier: ViewModifier {
    @Binding var request: AppRequest?

    let handle: (AppRequest) -> Void

    func body(content: Content) -> some View {
        content.onChange(of: request, initial: true) { handlePendingRequest() }
    }

    private func handlePendingRequest() {
        guard let request else { return }

        self.request = nil
        handle(request)
    }
}

extension View {
    func handles(
        _ request: Binding<AppRequest?>,
        handle: @escaping (AppRequest) -> Void
    ) -> some View {
        modifier(RequestHandlingModifier(request: request, handle: handle))
    }
}
