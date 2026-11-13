//
//  CategoryRepositorySpy.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

public final class CategoryRepositorySpy: CategoryRepository {
    public struct Save: Equatable {
        public let categoryID: UUID?
        public let name: String
        public let icon: String

        public init(categoryID: UUID?, name: String, icon: String) {
            self.categoryID = categoryID
            self.name = name
            self.icon = icon
        }
    }

    public var storedCategories: [EventCategory]
    public var error: CategoryError?
    public var readError: CategoryError?

    public private(set) var saves: [Save] = []
    public private(set) var deletedIDs: [UUID] = []
    public private(set) var orders: [[UUID]] = []
    public private(set) var seedCount = 0

    public init(
        storedCategories: [EventCategory] = [],
        error: CategoryError? = nil,
        readError: CategoryError? = nil
    ) {
        self.storedCategories = storedCategories
        self.error = error
        self.readError = readError
    }

    public func changes() -> AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }

    public func categories() throws(CategoryError) -> [EventCategory] {
        if let readError {
            throw readError
        }

        return storedCategories
    }

    public func save(categoryID: UUID?, name: String, icon: String) throws(CategoryError) {
        saves.append(Save(categoryID: categoryID, name: name, icon: icon))
        try failIfNeeded()
    }

    public func delete(categoryID: UUID) throws(CategoryError) {
        deletedIDs.append(categoryID)
        try failIfNeeded()
    }

    public func reorder(categoryIDs: [UUID]) throws(CategoryError) {
        orders.append(categoryIDs)
        try failIfNeeded()
    }

    public func seedBuiltInCategories() throws(CategoryError) {
        seedCount += 1
        try failIfNeeded()
    }

    private func failIfNeeded() throws(CategoryError) {
        if let error {
            throw error
        }
    }
}
