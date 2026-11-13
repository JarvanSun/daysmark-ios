//
//  CategoryRepository.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

@MainActor
public protocol CategoryRepository: AnyObject {
    func changes() -> AsyncStream<Void>

    func categories() throws(CategoryError) -> [EventCategory]

    func save(categoryID: UUID?, name: String, icon: String) throws(CategoryError)

    func delete(categoryID: UUID) throws(CategoryError)

    func reorder(categoryIDs: [UUID]) throws(CategoryError)

    func seedBuiltInCategories() throws(CategoryError)
}
