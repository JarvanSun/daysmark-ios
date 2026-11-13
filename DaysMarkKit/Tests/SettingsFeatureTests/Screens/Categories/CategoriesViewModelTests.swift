//
//  CategoriesViewModelTests.swift
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

struct CategoriesViewModelTests {
    @Test func reloadThenListsOnlyCategoriesThatAreNotDeleted() {
        // Given
        let kept = EventCategory(name: "Travel", icon: "airplane")
        let deleted = EventCategory(name: "Old", icon: "star")
        deleted.deletedAt = .mockNow
        let repository = CategoryRepositorySpy()
        repository.storedCategories = [kept, deleted]
        let viewModel = makeViewModel(repository: repository)

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.content.rows.map(\.id) == [kept.id])
        #expect(viewModel.issue == nil)
    }

    @Test func reloadWhenReadingFailsThenShowsTheIssue() {
        // Given
        let repository = CategoryRepositorySpy()
        repository.readError = .storeFailure
        let viewModel = makeViewModel(repository: repository)

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.issue == .unknown)
    }

    @Test func observeStoreThenLoadsTheStoredCategories() async {
        // Given
        let category = EventCategory(name: "Travel", icon: "airplane")
        let repository = CategoryRepositorySpy()
        repository.storedCategories = [category]
        let viewModel = makeViewModel(repository: repository)

        // When
        await viewModel.observeStore()

        // Then
        #expect(viewModel.content.rows.map(\.id) == [category.id])
    }

    @Test func addCategoryThenShowsTheEditorForANewCategory() {
        // Given
        let router = SettingsRouterSpy()
        let viewModel = makeViewModel(router: router)

        // When
        viewModel.addCategory()

        // Then
        #expect(router.calls == [.categoryEditor(.new)])
    }

    @Test func renameThenShowsTheEditorForThatCategory() {
        // Given
        let router = SettingsRouterSpy()
        let category = EventCategory(name: "Travel", icon: "airplane")
        let viewModel = makeViewModel(showing: [category], router: router)
        let row = viewModel.content.rows[0]

        // When
        viewModel.rename(row)

        // Then
        #expect(
            router.calls == [
                .categoryEditor(.existing(id: category.id, name: "Travel", icon: "airplane"))
            ]
        )
    }

    @Test func moveThenWritesTheSortOrderOfEveryCategory() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let service = SwiftDataCategoryRepository.mock(in: container)
        try service.seedBuiltInCategories()
        try service.save(categoryID: nil, name: "Travel", icon: "airplane")
        let travel = try #require(try categories(in: context).first { $0.name == "Travel" })
        let viewModel = makeViewModel(repository: service)
        viewModel.reload()

        // When
        viewModel.move(from: [viewModel.content.rows.count - 1], to: 0)

        // Then
        let reordered = try categories(in: context)
        #expect(viewModel.issue == nil)
        #expect(reordered.first?.id == travel.id)
        #expect(reordered.map(\.sortOrder) == Array(0..<reordered.count))
    }

    @Test func moveThenKeepsTheOrderWhenBuiltInsAreSeededAgain() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let service = SwiftDataCategoryRepository.mock(in: container)
        try service.seedBuiltInCategories()
        let viewModel = makeViewModel(repository: service)
        viewModel.reload()
        viewModel.move(from: [viewModel.content.rows.count - 1], to: 0)
        let reordered = try categories(in: context).map(\.id)

        // When
        try service.seedBuiltInCategories()

        // Then
        #expect(try categories(in: context).map(\.id) == reordered)
    }

    @Test func moveWhenReorderingFailsThenShowsTheIssue() {
        // Given
        let viewModel = makeViewModel(
            showing: [EventCategory(name: "Travel", icon: "airplane")],
            repository: CategoryRepositorySpy(error: .storeFailure)
        )

        // When
        viewModel.move(from: [0], to: 1)

        // Then
        #expect(viewModel.issue == .unknown)
    }

    @Test func deleteWhenCategoryHasNoEventsThenDeletesItAtOnce() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let category = EventCategory(name: "Empty", icon: "star")
        context.insert(category)
        try context.save()
        let viewModel = makeViewModel(repository: SwiftDataCategoryRepository.mock(in: container))
        let row = try categoryRow(for: category, in: viewModel)

        // When
        viewModel.delete(row)

        // Then
        #expect(viewModel.pendingDeletion == nil)
        #expect(viewModel.issue == nil)
        #expect(category.deletedAt != nil)
        #expect(
            try categories(in: context).map(\.builtInKind) == [.important]
        )
    }

    @Test func deleteWhenCategoryHasEventsThenWaitsForConfirmation() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let travel = try makeCategoryWithEvent(in: container).category
        let viewModel = makeViewModel(repository: SwiftDataCategoryRepository.mock(in: container))
        let row = try categoryRow(for: travel, in: viewModel)

        // When
        viewModel.delete(row)

        // Then
        #expect(viewModel.pendingDeletion == row)
        #expect(travel.deletedAt == nil)
    }

    @Test func cancelDeletionThenKeepsTheCategory() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let travel = try makeCategoryWithEvent(in: container).category
        let viewModel = makeViewModel(repository: SwiftDataCategoryRepository.mock(in: container))
        viewModel.delete(try categoryRow(for: travel, in: viewModel))

        // When
        viewModel.cancelDeletion()

        // Then
        #expect(viewModel.pendingDeletion == nil)
        #expect(travel.deletedAt == nil)
    }

    @Test func confirmDeletionThenDeletesTheCategoryAndMovesItsEvents() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let (travel, event) = try makeCategoryWithEvent(in: container)
        let viewModel = makeViewModel(repository: SwiftDataCategoryRepository.mock(in: container))
        viewModel.delete(try categoryRow(for: travel, in: viewModel))

        // When
        viewModel.confirmDeletion()

        // Then
        #expect(viewModel.pendingDeletion == nil)
        #expect(viewModel.issue == nil)
        #expect(travel.deletedAt != nil)
        #expect(event.categoryID == BuiltInCategory.important.id)
    }

    @Test func confirmDeletionWithoutAPendingDeletionThenDeletesNothing() {
        // Given
        let repository = CategoryRepositorySpy()
        let viewModel = makeViewModel(repository: repository)

        // When
        viewModel.confirmDeletion()

        // Then
        #expect(repository.deletedIDs.isEmpty)
    }

    @Test func deleteWhenCategoryIsBuiltInThenShowsTheIssueAndKeepsIt() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let service = SwiftDataCategoryRepository.mock(in: container)
        try service.seedBuiltInCategories()
        let builtIn = try #require(try categories(in: context).first)
        let viewModel = makeViewModel(repository: service)

        // When
        viewModel.delete(try categoryRow(for: builtIn, in: viewModel))

        // Then
        #expect(viewModel.issue == .builtInCategory)
        #expect(builtIn.deletedAt == nil)
    }

    @Test func acknowledgeIssueThenClearsTheIssue() {
        // Given
        let viewModel = makeViewModel(
            showing: [EventCategory(name: "Travel", icon: "airplane")],
            repository: CategoryRepositorySpy(error: .storeFailure)
        )
        viewModel.delete(viewModel.content.rows[0])

        // When
        viewModel.acknowledgeIssue()

        // Then
        #expect(viewModel.issue == nil)
    }
}

private extension CategoriesViewModelTests {
    func makeViewModel(
        repository: CategoryRepository = CategoryRepositorySpy(),
        router: SettingsRouterSpy = .init()
    ) -> CategoriesViewModel {
        .init(repository: repository, router: router)
    }

    func makeViewModel(
        showing categories: [EventCategory],
        repository: CategoryRepositorySpy = .init(),
        router: SettingsRouterSpy = .init()
    ) -> CategoriesViewModel {
        repository.storedCategories = categories
        let viewModel = makeViewModel(repository: repository, router: router)
        viewModel.reload()

        return viewModel
    }

    func categoryRow(for category: EventCategory, in viewModel: CategoriesViewModel) throws
        -> CategoriesContent.Row
    {
        viewModel.reload()

        return try #require(viewModel.content.rows.first { $0.id == category.id })
    }

    func categories(in context: ModelContext) throws -> [EventCategory] {
        try context.fetch(FetchDescriptor<EventCategory>(sortBy: [SortDescriptor(\.sortOrder)]))
            .filter { $0.deletedAt == nil }
    }

    func makeCategoryWithEvent(
        in container: ModelContainer
    ) throws -> (category: EventCategory, event: CountdownEvent) {
        let context = container.mainContext
        let service = SwiftDataCategoryRepository.mock(in: container)
        try service.seedBuiltInCategories()
        try service.save(categoryID: nil, name: "Travel", icon: "airplane")
        let travel = try #require(try categories(in: context).first { $0.name == "Travel" })
        let event = CountdownEvent.mock(category: travel)
        context.insert(event)
        try context.save()

        return (travel, event)
    }
}
