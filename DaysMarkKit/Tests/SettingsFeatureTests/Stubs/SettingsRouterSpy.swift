//
//  SettingsRouterSpy.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

@testable import SettingsFeature

final class SettingsRouterSpy: SettingsRouting {
    enum Call: Equatable {
        case notifications
        case categories
        case importDates
        case widgets
        case siriAndShortcuts
        case recentlyDeleted
        case categoryEditor(CategoryEditorTarget)
        case dismissCategoryEditor
    }

    private(set) var calls: [Call] = []

    func showNotifications() {
        calls.append(.notifications)
    }

    func showCategories() {
        calls.append(.categories)
    }

    func showImport() {
        calls.append(.importDates)
    }

    func showWidgets() {
        calls.append(.widgets)
    }

    func showSiriAndShortcuts() {
        calls.append(.siriAndShortcuts)
    }

    func showRecentlyDeleted() {
        calls.append(.recentlyDeleted)
    }

    func showCategoryEditor(for target: CategoryEditorTarget) {
        calls.append(.categoryEditor(target))
    }

    func dismissCategoryEditor() {
        calls.append(.dismissCategoryEditor)
    }
}
