//
//  CategoryEditorViewModelTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/10/07.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore
@testable import SettingsFeature

struct CategoryEditorViewModelTests {
    @Test func initForANewCategoryThenStartsEmpty() {
        // Given / When
        let viewModel = makeViewModel(target: .new)

        // Then
        #expect(viewModel.name.isEmpty)
    }

    @Test func initForAnExistingCategoryThenPrefillsItsName() {
        // Given
        let category = EventCategory(name: "Travel", icon: "airplane")

        // When
        let viewModel = makeViewModel(target: .mock(category))

        // Then
        #expect(viewModel.name == "Travel")
    }

    @Test func nameWhenEditedThenLeavesTheStoredCategoryUntouched() {
        // Given
        let category = EventCategory(name: "Travel", icon: "airplane")
        let viewModel = makeViewModel(target: .mock(category))

        // When
        viewModel.name = "Changed draft"

        // Then
        #expect(category.name == "Travel")
    }

    @Test(arguments: [("", false), ("   ", false), ("Travel", true)])
    func canSaveThenNeedsANameThatIsNotBlank(name: String, expected: Bool) {
        // Given
        let viewModel = makeViewModel(target: .new)

        // When
        viewModel.name = name

        // Then
        #expect(viewModel.canSave == expected)
    }

    @Test func saveForANewCategoryThenStoresItAndClosesTheEditor() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let router = SettingsRouterSpy()
        let viewModel = makeViewModel(
            target: .new,
            repository: SwiftDataCategoryRepository.mock(in: container),
            router: router
        )
        viewModel.name = "Travel"

        // When
        viewModel.save()

        // Then
        #expect(viewModel.issue == nil)
        #expect(
            try context.fetch(FetchDescriptor<EventCategory>()).contains { $0.name == "Travel" }
        )
        #expect(router.calls == [.dismissCategoryEditor])
    }

    @Test func saveForAnExistingCategoryThenRenamesItInPlace() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let category = EventCategory(name: "Old", icon: "star")
        context.insert(category)
        try context.save()
        let viewModel = makeViewModel(
            target: .mock(category),
            repository: SwiftDataCategoryRepository.mock(in: container)
        )
        viewModel.name = "New"

        // When
        viewModel.save()

        // Then
        let stored = try context.fetch(FetchDescriptor<EventCategory>())
        #expect(stored.map(\.name) == ["New"])
        #expect(category.icon == "star")
    }

    @Test func saveThenTrimsTheNameAndUsesTheDefaultIconForANewCategory() {
        // Given
        let repository = CategoryRepositorySpy()
        let viewModel = makeViewModel(target: .new, repository: repository)
        viewModel.name = "  Travel\n"

        // When
        viewModel.save()

        // Then
        #expect(repository.saves == [.init(categoryID: nil, name: "Travel", icon: "star")])
    }

    @Test func saveWhenNameIsBlankThenStoresNothing() {
        // Given
        let repository = CategoryRepositorySpy()
        let router = SettingsRouterSpy()
        let viewModel = makeViewModel(target: .new, repository: repository, router: router)
        viewModel.name = "   "

        // When
        viewModel.save()

        // Then
        #expect(repository.saves.isEmpty)
        #expect(router.calls.isEmpty)
    }

    @Test func saveWhenTheServiceRejectsTheNameThenShowsTheIssueAndStaysOpen() {
        // Given
        let router = SettingsRouterSpy()
        let viewModel = makeViewModel(
            target: .new,
            repository: CategoryRepositorySpy(error: .emptyName),
            router: router
        )
        viewModel.name = "Travel"

        // When
        viewModel.save()

        // Then
        #expect(viewModel.issue == .emptyName)
        #expect(router.calls.isEmpty)
    }

    @Test func acknowledgeIssueThenClearsTheIssue() {
        // Given
        let viewModel = makeViewModel(
            target: .new,
            repository: CategoryRepositorySpy(error: .storeFailure)
        )
        viewModel.name = "Travel"
        viewModel.save()

        // When
        viewModel.acknowledgeIssue()

        // Then
        #expect(viewModel.issue == nil)
    }

    @Test func cancelThenClosesTheEditorWithoutSaving() {
        // Given
        let repository = CategoryRepositorySpy()
        let router = SettingsRouterSpy()
        let viewModel = makeViewModel(target: .new, repository: repository, router: router)
        viewModel.name = "Travel"

        // When
        viewModel.cancel()

        // Then
        #expect(repository.saves.isEmpty)
        #expect(router.calls == [.dismissCategoryEditor])
    }

    private func makeViewModel(
        target: CategoryEditorTarget,
        repository: CategoryRepository = CategoryRepositorySpy(),
        router: SettingsRouterSpy = .init()
    ) -> CategoryEditorViewModel {
        .init(target: target, repository: repository, router: router)
    }
}
