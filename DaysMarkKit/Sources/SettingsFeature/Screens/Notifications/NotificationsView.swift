//
//  NotificationsView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/07/28.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct NotificationsView: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(NotificationPreferences.Key.newReminderMinuteOfDay.rawValue)
    private var newReminderMinuteOfDay = NotificationPreferences()
        .defaultNewReminderTime.minuteOfDay

    let viewModel: NotificationsViewModel

    var body: some View {
        PageScrollView {
            SettingsGroup {
                SettingsRow(
                    Text("settings.notifications.permission.title", bundle: .module),
                    symbol: .bellBadge,
                    value: Text(viewModel.permission.title)
                )

                if viewModel.permission == .notDetermined {
                    Button {
                        viewModel.enableNotifications()
                    } label: {
                        SettingsRow(
                            Text("settings.notifications.permission.enable", bundle: .module),
                            symbol: .checkmarkCircle
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.activity == .requestingPermission)
                }

                if viewModel.permission == .denied {
                    SystemSettingsLink {
                        SettingsRow(
                            Text("settings.notifications.permission.openSettings", bundle: .module),
                            symbol: .gear
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            SettingsGroup(Text("settings.notifications.defaults.title", bundle: .module)) {
                ReminderTimePicker(
                    minuteOfDay: newReminderMinuteOfDay,
                    onChange: { newReminderMinuteOfDay = $0 }
                ) {
                    SettingsLabel(
                        title: Text(
                            "settings.notifications.defaults.reminderTime",
                            bundle: .module
                        ),
                        symbol: .clock
                    )
                }
                .frame(minHeight: dimensions.rowMinimumHeight)
            }
        }
        .navigationTitle(Text("settings.notifications.title", bundle: .module))
        .task(id: scenePhase) { await viewModel.refresh() }
        .task(id: viewModel.permissionRequest) { await viewModel.requestPermission() }
    }
}

#if DEBUG
#Preview("Notifications", arguments: NotificationsPreviewState.allCases) { state in
    NavigationStack {
        NotificationsView(viewModel: PreviewObjectPool().notificationsViewModel(state))
    }
    .environment(\.locale, state.locale)
}
#endif
