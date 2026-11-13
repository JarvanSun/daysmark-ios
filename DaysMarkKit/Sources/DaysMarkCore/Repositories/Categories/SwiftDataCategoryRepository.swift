//
//  SwiftDataCategoryRepository.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation
import SwiftData

@MainActor
public final class SwiftDataCategoryRepository {
    private let container: ModelContainer
    private let events: EventRepository
    private let storeChanges: StoreChanges
    private let now: () -> Date

    public init(
        container: ModelContainer,
        events: EventRepository,
        storeChanges: StoreChanges,
        now: @escaping () -> Date
    ) {
        self.container = container
        self.events = events
        self.storeChanges = storeChanges
        self.now = now
    }

    var context: ModelContext { container.mainContext }

    func write(_ change: () throws -> Void) throws(CategoryError) {
        do {
            try change()
        } catch {
            context.rollback()
            throw CategoryError(error)
        }
    }
}

// MARK: - CategoryRepository

extension SwiftDataCategoryRepository: CategoryRepository {
    public func changes() -> AsyncStream<Void> {
        storeChanges.stream()
    }

    public func categories() throws(CategoryError) -> [EventCategory] {
        do {
            return try context.fetch(
                FetchDescriptor<EventCategory>(sortBy: [SortDescriptor(\.sortOrder)])
            )
        } catch {
            throw CategoryError(error)
        }
    }

    public func save(categoryID: UUID?, name: String, icon: String) throws(CategoryError) {
        try write {
            switch categoryID {
            case let categoryID?: try update(category(withID: categoryID), name: name, icon: icon)
            case nil: try create(name: name, icon: icon)
            }
        }
    }

    public func delete(categoryID: UUID) throws(CategoryError) {
        try write {
            try delete(category(withID: categoryID))
        }
    }

    public func reorder(categoryIDs: [UUID]) throws(CategoryError) {
        try write {
            let categories = try activeCategories()
            var ordered: [EventCategory] = categoryIDs.compactMap { id in
                categories.first { $0.id == id }
            }

            for category in categories where !ordered.contains(where: { $0 === category }) {
                ordered.append(category)
            }

            for (index, category) in ordered.enumerated() where category.sortOrder != index {
                category.sortOrder = index
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
}

// MARK: - Private

private extension SwiftDataCategoryRepository {
    func category(withID id: UUID) throws -> EventCategory {
        let category = try context.fetch(FetchDescriptor<EventCategory>()).first { $0.id == id }

        guard let category else { throw CategoryError.categoryUnavailable }

        return category
    }

    func activeCategories() throws -> [EventCategory] {
        try context.fetch(FetchDescriptor<EventCategory>(sortBy: [SortDescriptor(\.sortOrder)]))
            .filter { $0.deletedAt == nil }
    }

    func create(name: String, icon: String) throws {
        let name = try validated(name)
        let category = EventCategory(
            name: name,
            icon: icon,
            sortOrder: try nextCustomSortOrder()
        )
        context.insert(category)

        try context.save()
    }

    func update(_ category: EventCategory, name: String, icon: String) throws {
        if !category.isBuiltIn {
            category.name = try validated(name)
            category.icon = icon
        }

        try context.save()
    }

    func delete(_ category: EventCategory) throws {
        guard !category.isBuiltIn else { throw CategoryError.cannotDeleteBuiltIn }

        let categories = try context.fetch(FetchDescriptor<EventCategory>())
        let important =
            categories.first { $0.id == BuiltInCategory.important.id }
            ?? EventCategory(builtIn: .important)

        if !categories.contains(where: { $0 === important }) {
            context.insert(important)
        }

        try context.transaction {
            try events.moveEvents(from: category.id, to: important.id)
            category.deletedAt = now()
            try context.save()
        }
    }

    func validated(_ name: String) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { throw CategoryError.emptyName }

        return trimmed
    }

    func nextCustomSortOrder() throws -> Int {
        let highest = try context.fetch(FetchDescriptor<EventCategory>()).map(\.sortOrder).max()

        return (highest ?? 0) + 1
    }
}
