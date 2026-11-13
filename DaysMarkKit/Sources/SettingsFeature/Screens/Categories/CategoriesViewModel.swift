//
//  CategoriesViewModel.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/07/31.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class CategoriesViewModel {
    private(set) var content = CategoriesContent()
    private(set) var pendingDeletion: CategoriesContent.Row?
    private(set) var issue: CategoriesIssue?

    private let repository: CategoryRepository
    private let router: SettingsRouting

    init(repository: CategoryRepository, router: SettingsRouting) {
        self.repository = repository
        self.router = router
    }

    func observeStore() async {
        reload()

        for await _ in repository.changes() {
            reload()
        }
    }

    func reload() {
        do {
            let categories = try repository.categories().filter { $0.deletedAt == nil }

            content = CategoriesContent(rows: categories.map(CategoriesContent.Row.init))
        } catch {
            issue = CategoriesIssue(error)
        }
    }

    func addCategory() {
        router.showCategoryEditor(for: .new)
    }

    func rename(_ row: CategoriesContent.Row) {
        router.showCategoryEditor(for: .existing(id: row.id, name: row.name, icon: row.icon))
    }

    func move(from offsets: IndexSet, to destination: Int) {
        let order = content.order(moving: offsets, to: destination)

        perform(try repository.reorder(categoryIDs: order))
    }

    func delete(_ row: CategoriesContent.Row) {
        guard !row.hasEvents else {
            pendingDeletion = row
            return
        }

        perform(try repository.delete(categoryID: row.id))
    }

    func confirmDeletion() {
        guard let pendingDeletion else { return }

        self.pendingDeletion = nil
        perform(try repository.delete(categoryID: pendingDeletion.id))
    }

    func cancelDeletion() {
        pendingDeletion = nil
    }

    func acknowledgeIssue() {
        issue = nil
    }

    private func perform(_ change: @autoclosure () throws(CategoryError) -> Void) {
        do {
            try change()
            issue = nil
        } catch {
            issue = CategoriesIssue(error)
        }
    }
}
