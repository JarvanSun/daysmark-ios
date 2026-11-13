//
//  CategoryEditorViewModel.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/07/31.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class CategoryEditorViewModel {
    var name: String

    let target: CategoryEditorTarget
    private let repository: CategoryRepository
    private let router: SettingsRouting

    private(set) var issue: CategoriesIssue?

    var canSave: Bool {
        !trimmedName.isEmpty
    }

    init(target: CategoryEditorTarget, repository: CategoryRepository, router: SettingsRouting) {
        self.target = target
        self.repository = repository
        self.router = router
        name = target.name
    }

    func save() {
        guard canSave else { return }

        do {
            try repository.save(categoryID: target.categoryID, name: trimmedName, icon: target.icon)
            router.dismissCategoryEditor()
        } catch {
            issue = CategoriesIssue(error)
        }
    }

    func cancel() {
        router.dismissCategoryEditor()
    }

    func acknowledgeIssue() {
        issue = nil
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
