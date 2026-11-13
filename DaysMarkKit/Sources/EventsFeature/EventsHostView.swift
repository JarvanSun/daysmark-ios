//
//  EventsHostView.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import SwiftUI

public struct EventsHostView: View {
    @Binding private var request: AppRequest?

    private let dependencies: EventsDependencies

    public init(dependencies: EventsDependencies, request: Binding<AppRequest?>) {
        self.dependencies = dependencies
        _request = request
    }

    public var body: some View {
        EventsNavigationHost(dependencies: dependencies, request: $request)
    }
}

#if DEBUG
#Preview("Events") {
    @Previewable @State var request: AppRequest?

    let pool = PreviewObjectPool()
    let container = pool.modelContainer()

    EventsHostView(
        dependencies: pool.eventsDependencies(in: container),
        request: $request
    )
}
#endif
