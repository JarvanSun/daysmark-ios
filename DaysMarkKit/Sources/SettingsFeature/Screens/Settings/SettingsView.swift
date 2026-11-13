//
//  SettingsView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/07/25.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct SettingsView: View {
    let version: String
    let build: String
    let router: SettingsRouting

    var body: some View {
        PageScrollView {
            SettingsGroup {
                Button {
                    router.showNotifications()
                } label: {
                    SettingsRow(
                        Text("settings.entry.notifications", bundle: .module),
                        symbol: .bell,
                        showsDisclosure: true
                    )
                }

                Button {
                    router.showCategories()
                } label: {
                    SettingsRow(
                        Text("settings.entry.categories", bundle: .module),
                        symbol: .folder,
                        showsDisclosure: true
                    )
                }
            }

            SettingsGroup(Text("settings.section.connections", bundle: .module)) {
                Button {
                    router.showImport()
                } label: {
                    SettingsRow(
                        Text("settings.entry.importDates", bundle: .module),
                        symbol: .squareAndArrowDown,
                        showsDisclosure: true
                    )
                }

                Button {
                    router.showWidgets()
                } label: {
                    SettingsRow(
                        Text("settings.entry.widgets", bundle: .module),
                        symbol: .rectangle3Group,
                        showsDisclosure: true
                    )
                }

                Button {
                    router.showSiriAndShortcuts()
                } label: {
                    SettingsRow(
                        Text("settings.entry.siriAndShortcuts", bundle: .module),
                        symbol: .waveform,
                        showsDisclosure: true
                    )
                }
            }

            SettingsGroup(Text("settings.section.app", bundle: .module)) {
                SystemSettingsLink {
                    SettingsRow(Text("settings.app.language", bundle: .module), symbol: .globe)
                }

                Button {
                    router.showRecentlyDeleted()
                } label: {
                    SettingsRow(
                        Text("settings.entry.recentlyDeleted", bundle: .module),
                        symbol: .trash,
                        showsDisclosure: true
                    )
                }
            }

            Text("settings.about.version \(version) \(build)", bundle: .module)
                .textStyle(DaysMarkColor.textTertiary, DaysMarkFont.footnote)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .navigationTitle(Text("settings.title", bundle: .module))
        .navigationBarTitleDisplayMode(.large)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SettingsView(version: "1.0", build: "1", router: PreviewObjectPool().router)
    }
}
#endif
