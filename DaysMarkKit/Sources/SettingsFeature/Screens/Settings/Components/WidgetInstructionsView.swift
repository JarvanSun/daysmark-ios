//
//  WidgetInstructionsView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct WidgetInstructionsView: View {
    var body: some View {
        PageScrollView {
            SettingsGroup(footnote: Text("settings.widgets.kinds.footnote", bundle: .module)) {
                SettingsRow(
                    Text("settings.widgets.focus.title", bundle: .module),
                    subtitle: Text("settings.widgets.focus.subtitle", bundle: .module),
                    symbol: .scope
                )

                SettingsRow(
                    Text("settings.widgets.list.title", bundle: .module),
                    subtitle: Text("settings.widgets.list.subtitle", bundle: .module),
                    symbol: .listBullet
                )
            }

            SettingsGroup(Text("settings.widgets.adding.title", bundle: .module)) {
                Text("settings.widgets.adding.steps", bundle: .module)
                    .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.rowTitle)
            }
        }
        .navigationTitle(Text("settings.widgets.title", bundle: .module))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        WidgetInstructionsView()
    }
}
#endif
