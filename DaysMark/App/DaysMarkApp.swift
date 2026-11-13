//
//  DaysMarkApp.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/07/25.
//

import SwiftUI

@main
struct DaysMarkApp: App {
    @UIApplicationDelegateAdaptor private var notifications: NotificationRequestDelegate

    @Environment(\.scenePhase) private var scenePhase

    private let dependencies: AppDependencies
    private let lifecycle: AppLifecycle
    private let rootViewModel: AppRootViewModel

    init() {
        dependencies = AppDependencies(configuration: AppConfiguration(bundle: .main))
        lifecycle = dependencies.lifecycle()
        rootViewModel = dependencies.rootViewModel()

        dependencies.registerIntentDependencies()
        lifecycle.launch()
    }

    var body: some Scene {
        WindowGroup {
            AppRoot(
                viewModel: rootViewModel,
                dependencies: dependencies,
                notificationRequests: notifications.requests
            )
            .task { await lifecycle.start() }
        }
        .commands { AppCommands() }
        .onChange(of: scenePhase) { _, phase in lifecycle.sceneChanged(to: phase) }
    }
}
