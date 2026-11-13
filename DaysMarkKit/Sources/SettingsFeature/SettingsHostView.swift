//
//  SettingsHostView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import SwiftUI

public struct SettingsHostView: View {
    private let dependencies: SettingsDependencies
    private let page: SettingsPage

    public init(dependencies: SettingsDependencies, page: SettingsPage) {
        self.dependencies = dependencies
        self.page = page
    }

    public var body: some View {
        SettingsNavigationHost(dependencies: dependencies, page: page)
    }
}

#if DEBUG
#Preview("Settings") {
    NavigationStack {
        SettingsHostView(dependencies: PreviewObjectPool().settingsDependencies(), page: .root)
    }
}
#endif
