//
//  SiriShortcutsView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct SiriShortcutsView: View {
    var body: some View {
        PageScrollView {
            SettingsGroup(footnote: Text("settings.siri.actions.footnote", bundle: .module)) {
                SettingsRow(
                    Text("settings.siri.actions.find", bundle: .module),
                    symbol: .calendarBadgeClock
                )

                SettingsRow(Text("settings.siri.actions.distance", bundle: .module), symbol: .clock)

                SettingsRow(Text("settings.siri.actions.create", bundle: .module), symbol: .plus)

                SettingsRow(Text("settings.siri.actions.edit", bundle: .module), symbol: .pencil)
            }

            SettingsGroup(Text("settings.siri.privacy.title", bundle: .module)) {
                Text("settings.siri.privacy.message", bundle: .module)
                    .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.rowTitle)
            }
        }
        .navigationTitle(Text("settings.siri.title", bundle: .module))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SiriShortcutsView()
    }
}
#endif
