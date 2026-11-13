//
//  SettingsRouting.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

protocol SettingsRouting: AnyObject {
    func showNotifications()
    func showCategories()
    func showImport()
    func showWidgets()
    func showSiriAndShortcuts()
    func showRecentlyDeleted()
    func showCategoryEditor(for target: CategoryEditorTarget)
    func dismissCategoryEditor()
}
