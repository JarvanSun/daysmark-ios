//
//  SystemSettingsLink.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI
import UIKit

struct SystemSettingsLink<Label: View>: View {
    private let label: () -> Label

    init(@ViewBuilder label: @escaping () -> Label) {
        self.label = label
    }

    var body: some View {
        switch URL(string: UIApplication.openSettingsURLString) {
        case .some(let url): Link(destination: url, label: label)
        case nil: EmptyView()
        }
    }
}

#if DEBUG
#Preview {
    SystemSettingsLink {
        Text("settings.import.issue.openSettings", bundle: .module)
    }
}
#endif
