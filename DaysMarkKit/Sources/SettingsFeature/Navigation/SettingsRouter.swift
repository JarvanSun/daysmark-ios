//
//  SettingsRouter.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Observation
import SunUserInterface

@Observable
final class SettingsRouter: FeatureRouting, SettingsRouting {
    var presentation: FeaturePresentation<SettingsDestination>?
    var path: [SettingsDestination] = []

    private let dependencies: SettingsDependencies

    var pushed: SettingsDestination? {
        get { path.last }
        set { path = newValue.map { [$0] } ?? [] }
    }

    init(dependencies: SettingsDependencies) {
        self.dependencies = dependencies
    }

    func view(for destination: SettingsDestination) -> SettingsDestinationView {
        SettingsDestinationView(destination: destination, dependencies: dependencies, router: self)
    }

    func showNotifications() {
        route(to: SettingsDestination.notifications)
    }

    func showCategories() {
        route(to: SettingsDestination.categories)
    }

    func showImport() {
        route(to: SettingsDestination.importDates)
    }

    func showWidgets() {
        route(to: SettingsDestination.widgets)
    }

    func showSiriAndShortcuts() {
        route(to: SettingsDestination.siriAndShortcuts)
    }

    func showRecentlyDeleted() {
        route(to: SettingsDestination.recentlyDeleted(highlighting: nil))
    }

    func showCategoryEditor(for target: CategoryEditorTarget) {
        present(.categoryEditor(target))
    }

    func dismissCategoryEditor() {
        presentation = nil
    }

    private func present(_ destination: SettingsDestination) {
        presentation = FeaturePresentation(
            destination: destination,
            style: view(for: destination).style
        )
    }
}
