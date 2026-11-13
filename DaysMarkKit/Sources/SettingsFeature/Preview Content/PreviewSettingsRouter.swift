//
//  PreviewSettingsRouter.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation

final class PreviewSettingsRouter: SettingsRouting {
    func showNotifications() {}

    func showCategories() {}

    func showImport() {}

    func showWidgets() {}

    func showSiriAndShortcuts() {}

    func showRecentlyDeleted() {}

    func showCategoryEditor(for target: CategoryEditorTarget) {}

    func dismissCategoryEditor() {}
}
#endif
