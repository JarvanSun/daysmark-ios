//
//  CategoriesContentTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import SwiftData
import Testing

@testable import SettingsFeature

struct CategoriesContentTests {
    @Test func rowThenDescribesTheCategory() throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let context = container.mainContext
        let birthday = EventCategory(builtIn: .birthday)
        let travel = EventCategory(name: "Travel", icon: "airplane")
        context.insert(birthday)
        context.insert(travel)
        context.insert(CountdownEvent.mock(category: travel))
        try context.save()

        // When
        let rows = [birthday, travel].map(CategoriesContent.Row.init)

        // Then
        #expect(rows.map(\.id) == [birthday.id, travel.id])
        #expect(rows.map(\.name) == [birthday.displayName, "Travel"])
        #expect(rows.map(\.isBuiltIn) == [true, false])
        #expect(rows.map(\.hasEvents) == [false, true])
    }

    @Test(arguments: [
        (IndexSet(integer: 3), 0, [3, 0, 1, 2]),
        (IndexSet(integer: 0), 4, [1, 2, 3, 0]),
        (IndexSet(integer: 1), 3, [0, 2, 1, 3]),
        (IndexSet([0, 2]), 4, [1, 3, 0, 2]),
        (IndexSet(integer: 2), 2, [0, 1, 2, 3]),
    ])
    func orderThenMovesTheRowsToTheDestination(
        offsets: IndexSet,
        destination: Int,
        expected: [Int]
    ) {
        // Given
        let categories = ["A", "B", "C", "D"].map { EventCategory(name: $0, icon: "star") }
        let content = CategoriesContent(rows: categories.map(CategoriesContent.Row.init))

        // When
        let order = content.order(moving: offsets, to: destination)

        // Then
        #expect(order == expected.map { categories[$0].id })
    }
}
