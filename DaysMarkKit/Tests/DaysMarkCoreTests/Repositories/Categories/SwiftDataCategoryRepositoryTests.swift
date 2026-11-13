//
//  SwiftDataCategoryRepositoryTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct SwiftDataCategoryRepositoryTests {
    @Test
    func seedBuiltInCategoriesThenStoresTheThreeKinds() throws {
        // Given
        let (service, context) = makeService()

        // When
        try service.seedBuiltInCategories()

        // Then
        let categories = try context.fetch(FetchDescriptor<EventCategory>())
        #expect(categories.count == 3)
        #expect(Set(categories.compactMap(\.builtInKind)) == Set(BuiltInCategory.allCases))
        #expect(Set(categories.map(\.id)) == Set(BuiltInCategory.allCases.map(\.id)))
    }

    @Test
    func seedBuiltInCategoriesWhenRepeatedThenChangesNothing() throws {
        // Given
        let (service, context) = makeService()

        // When
        try service.seedBuiltInCategories()
        try service.seedBuiltInCategories()
        try service.seedBuiltInCategories()

        // Then
        #expect(try context.fetch(FetchDescriptor<EventCategory>()).count == 3)
        #expect(!context.hasChanges)
    }

    @Test
    func seedBuiltInCategoriesWhenOneKindExistsThenAddsOnlyTheMissingKinds() throws {
        // Given
        let (service, context) = makeService()
        let birthday = EventCategory(builtIn: .birthday)
        context.insert(birthday)
        try context.save()

        // When
        try service.seedBuiltInCategories()

        // Then
        let categories = try context.fetch(FetchDescriptor<EventCategory>())
        #expect(categories.count == 3)
        #expect(
            categories.filter { $0.builtInKind == .birthday }.map(\.recordID) == [birthday.recordID]
        )
    }

    @Test
    func seedBuiltInCategoriesWhenAKindIsDuplicatedThenKeepsOneRecordPerKind() throws {
        // Given
        let (service, context) = makeService()
        context.insert(EventCategory(builtIn: .important))
        context.insert(EventCategory(builtIn: .important))
        try context.save()

        // When
        try service.seedBuiltInCategories()
        try service.seedBuiltInCategories()

        // Then
        let categories = try activeCategories(in: context)
        #expect(categories.count == 3)
        #expect(Set(categories.map(\.id)) == Set(BuiltInCategory.allCases.map(\.id)))
    }

    @Test
    func seedBuiltInCategoriesWhenDuplicatesOwnEventsThenConvergesWithoutLosingEvents() throws {
        // Given
        let (service, context) = makeService()
        try service.seedBuiltInCategories()
        var expected: [UUID: UUID] = [:]

        for _ in 0..<2 {
            for kind in BuiltInCategory.allCases {
                let duplicate = EventCategory(builtIn: kind)
                context.insert(duplicate)
                let event = CountdownEvent.mock(title: "Restore fixture", category: duplicate)
                context.insert(event)
                expected[event.id] = kind.id
            }
        }

        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<EventCategory>()) == 9)

        // When
        try service.seedBuiltInCategories()

        // Then
        let categories = try activeCategories(in: context)
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
        #expect(categories.count == 3)
        #expect(events.count == expected.count)

        for event in events {
            #expect(event.categoryID == expected[event.id])
            #expect(event.category?.id == expected[event.id])
            #expect(categories.contains { $0 === event.category })
        }

        try service.seedBuiltInCategories()
        #expect(try context.fetchCount(FetchDescriptor<EventCategory>()) == 3)
        #expect(!context.hasChanges)
    }

    @Test
    func seedBuiltInCategoriesWhenACustomCategorySharesAKindNameThenDoesNotMergeIt() throws {
        // Given
        let (service, context) = makeService()
        try service.seedBuiltInCategories()
        let custom = try addCategory(
            named: BuiltInCategory.birthday.displayName,
            icon: "star",
            with: service,
            in: context
        )
        let event = CountdownEvent.mock(title: "Scalar fixture")
        event.categoryID = BuiltInCategory.birthday.id
        event.category = nil
        context.insert(event)
        try context.save()

        // When
        try service.seedBuiltInCategories()

        // Then
        #expect(event.category?.builtInKind == .birthday)
        #expect(try activeCategories(in: context).count == 4)
        #expect(!custom.isBuiltIn)
    }

    @Test
    func seedBuiltInCategoriesWhenAnEventWaitsForItsCategoryThenKeepsItsCategoryID() throws {
        // Given
        let (service, context) = makeService()
        try service.seedBuiltInCategories()
        let important = try #require(
            try activeCategories(in: context).first { $0.builtInKind == .important }
        )
        let event = CountdownEvent.mock(title: "Pending fixture", category: important)
        let pendingCategoryID = UUID()
        event.categoryID = pendingCategoryID
        context.insert(event)
        try context.save()

        // When
        try service.seedBuiltInCategories()

        // Then
        #expect(event.categoryID == pendingCategoryID)
        #expect(event.category?.builtInKind == .important)
    }

    @Test
    func seedBuiltInCategoriesWhenStoredOnDiskThenTheWidgetRoleReadsTheConvergedStore() throws {
        // Given
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "CategoryRestore-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "Restore.store")
        let eventID: UUID

        do {
            let writer = try ModelContainer(
                for: Schema.mockCurrent,
                configurations: [ModelConfiguration.mockOnDisk(at: url)]
            )
            let context = writer.mainContext
            let service = SwiftDataCategoryRepository.mock(in: writer)
            try service.seedBuiltInCategories()
            let duplicate = EventCategory(builtIn: .birthday)
            context.insert(duplicate)
            let event = CountdownEvent.mock(title: "Widget fixture", category: duplicate)
            eventID = event.id
            context.insert(event)
            try context.save()

            // When
            try service.seedBuiltInCategories()
        }

        // Then
        let configuration = ModelConfiguration.mockReadOnly(at: url)
        #expect(!configuration.allowsSave)
        #expect(configuration.cloudKitContainerIdentifier == nil)
        let reader = try ModelContainer(for: Schema.mockCurrent, configurations: [configuration])
        let context = ModelContext(reader)
        #expect(try context.fetchCount(FetchDescriptor<EventCategory>()) == 3)
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
        #expect(events.count == 1)
        #expect(events.first?.id == eventID)
        #expect(events.first?.category?.builtInKind == .birthday)
        #expect(events.first?.categoryID == BuiltInCategory.birthday.id)
    }

    @Test
    func saveWhenNewThenStoresATrimmedCustomCategoryAfterTheBuiltIns() throws {
        // Given
        let (service, context) = makeService()
        try service.seedBuiltInCategories()

        // When
        try service.save(categoryID: nil, name: "  Travel  ", icon: "airplane")

        // Then
        let last = try #require(try activeCategories(in: context).last)
        #expect(last.name == "Travel")
        #expect(last.icon == "airplane")
        #expect(!last.isBuiltIn)
    }

    @Test
    func saveWhenTheNameIsBlankThenThrowsEmptyNameAndStoresNothing() throws {
        // Given
        let (service, context) = makeService()

        // When / Then
        #expect(throws: CategoryError.emptyName) {
            try service.save(categoryID: nil, name: "   ", icon: "star")
        }
        #expect(try context.fetch(FetchDescriptor<EventCategory>()).isEmpty)
        #expect(!context.hasChanges)
    }

    @Test
    func saveWhenReplacingACustomCategoryThenChangesItsNameAndIcon() throws {
        // Given
        let (service, context) = makeService()
        let custom = try addCategory(named: "Travel", icon: "airplane", with: service, in: context)

        // When
        try service.save(categoryID: custom.id, name: "Holidays", icon: "sun.max")

        // Then
        #expect(custom.name == "Holidays")
        #expect(custom.icon == "sun.max")
    }

    @Test
    func saveWhenReplacingABuiltInCategoryThenKeepsItsNameAndIcon() throws {
        // Given
        let (service, context) = makeService()
        try service.seedBuiltInCategories()
        let builtIn = try #require(
            try context.fetch(FetchDescriptor<EventCategory>()).first {
                $0.builtInKind == .birthday
            }
        )

        // When
        try service.save(categoryID: builtIn.id, name: "Hacked", icon: "star")

        // Then
        #expect(builtIn.name.isEmpty)
        #expect(builtIn.displayName == BuiltInCategory.birthday.displayName)
        #expect(builtIn.icon == BuiltInCategory.birthday.icon)
    }

    @Test
    func saveWhenRenamingToBlankThenThrowsEmptyNameAndKeepsTheName() throws {
        // Given
        let (service, context) = makeService()
        let custom = try addCategory(named: "Travel", icon: "airplane", with: service, in: context)

        // When / Then
        #expect(throws: CategoryError.emptyName) {
            try service.save(categoryID: custom.id, name: "", icon: "airplane")
        }
        #expect(custom.name == "Travel")
    }

    @Test
    func saveWhenTheCategoryIsMissingThenThrowsCategoryUnavailable() {
        // Given
        let (service, _) = makeService()

        // When / Then
        #expect(throws: CategoryError.categoryUnavailable) {
            try service.save(categoryID: UUID(), name: "Travel", icon: "airplane")
        }
    }

    @Test
    func deleteWhenBuiltInThenThrowsCannotDeleteBuiltIn() throws {
        // Given
        let (service, context) = makeService()
        try service.seedBuiltInCategories()
        let builtIn = try #require(try context.fetch(FetchDescriptor<EventCategory>()).first)

        // When / Then
        #expect(throws: CategoryError.cannotDeleteBuiltIn) {
            try service.delete(categoryID: builtIn.id)
        }
        #expect(try context.fetch(FetchDescriptor<EventCategory>()).count == 3)
    }

    @Test
    func deleteWhenCustomThenMarksItDeletedAndSeedsImportant() throws {
        // Given
        let (service, context) = makeService()
        let custom = try addCategory(named: "Travel", icon: "airplane", with: service, in: context)

        // When
        try service.delete(categoryID: custom.id)

        // Then
        #expect(try activeCategories(in: context).map(\.builtInKind) == [.important])
        #expect(custom.deletedAt == .mockNow)
    }

    @Test
    func deleteWhenItsEventsCannotBeMovedThenKeepsTheCategoryAndThrowsStoreFailure() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let events = EventRepositorySpy(error: .storeFailure)
        let service = SwiftDataCategoryRepository(
            container: container,
            events: events,
            storeChanges: StoreChanges(notificationCenter: NotificationCenter()),
            now: { .mockNow }
        )
        let custom = try addCategory(
            named: "Travel",
            icon: "airplane",
            with: service,
            in: container.mainContext
        )

        // When / Then
        #expect(throws: CategoryError.storeFailure) { try service.delete(categoryID: custom.id) }
        #expect(
            events.moves == [
                EventRepositorySpy.Move(
                    categoryID: custom.id,
                    replacementID: BuiltInCategory.important.id
                )
            ]
        )
        #expect(custom.deletedAt == nil)
        #expect(!container.mainContext.hasChanges)
    }

    @Test
    func deleteWhenTheCategoryHasEventsThenMovesThemToImportantInANewRevision() throws {
        // Given
        let (service, context) = makeService()
        try service.seedBuiltInCategories()
        let custom = try addCategory(named: "Travel", icon: "airplane", with: service, in: context)
        let event = CountdownEvent.mock(title: "Trip", category: custom)
        context.insert(event)
        EventRevisionWriter(context: context).appendInitialRevision(for: event, at: .mockNow)
        try context.save()
        let originalRevisionID = event.currentRevisionID

        // When
        try service.delete(categoryID: custom.id)

        // Then
        let events = try context.fetch(FetchDescriptor<CountdownEvent>())
        #expect(events.count == 1)
        #expect(event.categoryID == BuiltInCategory.important.id)
        #expect(event.category?.builtInKind == .important)
        #expect(event.currentRevisionID != originalRevisionID)
        #expect(try activeCategories(in: context).contains { $0.id == custom.id } == false)
    }

    @Test
    func deleteWhenTheCategoryIsMissingThenThrowsCategoryUnavailable() {
        // Given
        let (service, _) = makeService()

        // When / Then
        #expect(throws: CategoryError.categoryUnavailable) {
            try service.delete(categoryID: UUID())
        }
    }

    @Test
    func reorderThenStoresTheGivenOrderAndAppendsTheRest() throws {
        // Given
        let (service, context) = makeService()
        try service.seedBuiltInCategories()
        let travel = try addCategory(named: "Travel", icon: "airplane", with: service, in: context)

        // When
        try service.reorder(categoryIDs: [travel.id, BuiltInCategory.birthday.id])

        // Then
        #expect(
            try activeCategories(in: context).map(\.id) == [
                travel.id,
                BuiltInCategory.birthday.id,
                BuiltInCategory.important.id,
                BuiltInCategory.anniversary.id,
            ]
        )
        #expect(!context.hasChanges)
    }
}

private extension SwiftDataCategoryRepositoryTests {
    func makeService() -> (SwiftDataCategoryRepository, ModelContext) {
        let container = ModelContainer.mockInMemory()

        return (.mock(in: container), container.mainContext)
    }

    func activeCategories(in context: ModelContext) throws -> [EventCategory] {
        try context.fetch(FetchDescriptor<EventCategory>(sortBy: [SortDescriptor(\.sortOrder)]))
            .filter { $0.deletedAt == nil }
    }

    func addCategory(
        named name: String,
        icon: String,
        with service: SwiftDataCategoryRepository,
        in context: ModelContext
    ) throws -> EventCategory {
        try service.save(categoryID: nil, name: name, icon: icon)

        return try #require(
            try context.fetch(FetchDescriptor<EventCategory>()).first { $0.name == name }
        )
    }
}
