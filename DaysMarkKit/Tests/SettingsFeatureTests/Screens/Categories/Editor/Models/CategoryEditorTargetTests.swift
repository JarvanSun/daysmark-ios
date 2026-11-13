//
//  CategoryEditorTargetTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import SettingsFeature

struct CategoryEditorTargetTests {
    @Test func newThenHasNoCategoryOrNameAndTheStarIcon() {
        // Given / When
        let target = CategoryEditorTarget.new

        // Then
        #expect(target.categoryID == nil)
        #expect(target.name.isEmpty)
        #expect(target.icon == "star")
    }

    @Test func existingThenCarriesTheCategory() {
        // Given
        let id = UUID()

        // When
        let target = CategoryEditorTarget.existing(id: id, name: "Travel", icon: "airplane")

        // Then
        #expect(target.categoryID == id)
        #expect(target.name == "Travel")
        #expect(target.icon == "airplane")
    }

    @Test(arguments: [
        (CategoryEditorTarget.new, "settings.categories.editor.title.new"),
        (
            .existing(id: UUID(), name: "Travel", icon: "airplane"),
            "settings.categories.editor.title.edit"
        ),
    ])
    func titleThenSaysWhetherTheCategoryIsNew(target: CategoryEditorTarget, key: String) {
        #expect(target.title.key == key)
    }
}
