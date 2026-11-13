//
//  SettingsDestinationView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import Foundation
import SunUserInterface
import SwiftUI

struct SettingsDestinationView: FeatureDestinationView {
    let destination: SettingsDestination
    let dependencies: SettingsDependencies
    let router: SettingsRouting

    var style: PresentingStyle {
        switch destination {
        case .categoryEditor: .sheet
        case .root, .notifications, .categories, .importDates, .widgets, .siriAndShortcuts,
            .recentlyDeleted:
            .push
        }
    }

    var body: some View {
        switch destination {
        case .root:
            SettingsView(
                version: dependencies.version,
                build: dependencies.build,
                router: router
            )
        case .notifications:
            ViewModelOwner(
                NotificationsViewModel(permissionRequester: dependencies.notificationPermission)
            ) {
                NotificationsView(viewModel: $0)
            }
        case .categories:
            ViewModelOwner(
                CategoriesViewModel(repository: dependencies.categories, router: router)
            ) {
                CategoriesView(viewModel: $0)
            }
        case .categoryEditor(let target):
            ViewModelOwner(
                CategoryEditorViewModel(
                    target: target,
                    repository: dependencies.categories,
                    router: router
                )
            ) {
                CategoryEditorView(viewModel: $0)
            }
        case .importDates:
            ViewModelOwner(
                ImportViewModel(
                    scanner: dependencies.importScanner,
                    applier: dependencies.importApplier
                )
            ) {
                ImportView(viewModel: $0)
            }
        case .widgets: WidgetInstructionsView()
        case .siriAndShortcuts: SiriShortcutsView()
        case .recentlyDeleted(let eventID):
            ViewModelOwner(
                RecentlyDeletedViewModel(
                    highlightedEventID: eventID,
                    repository: dependencies.events
                )
            ) {
                RecentlyDeletedView(viewModel: $0)
            }
        }
    }
}

private struct ViewModelOwner<ViewModel, Screen: View>: View {
    @State private var viewModel: ViewModel

    private let screen: (ViewModel) -> Screen

    init(
        _ viewModel: @autoclosure () -> ViewModel,
        @ViewBuilder screen: @escaping (ViewModel) -> Screen
    ) {
        _viewModel = State(initialValue: viewModel())
        self.screen = screen
    }

    var body: some View {
        screen(viewModel)
    }
}
