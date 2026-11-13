//
//  SettingsNavigationHost.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import SunUserInterface
import SwiftUI

struct SettingsNavigationHost: FeatureHost {
    @State private var router: SettingsRouter

    private let start: SettingsDestination

    var featureRouter: SettingsRouter { router }

    var addContentInNavigationView: Bool { false }

    var root: some View {
        router.view(for: start)
            .navigationDestination(item: $router.pushed) { router.view(for: $0) }
    }

    init(dependencies: SettingsDependencies, page: SettingsPage) {
        start = SettingsDestination(page)
        _router = State(initialValue: SettingsRouter(dependencies: dependencies))
    }
}
