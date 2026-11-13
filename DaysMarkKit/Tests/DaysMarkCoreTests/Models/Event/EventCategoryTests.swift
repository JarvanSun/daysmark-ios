//
//  EventCategoryTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import DaysMarkCore

struct EventCategoryTests {
    @Test
    func displayNameWhenBuiltInThenComesFromTheKind() {
        // Given / When
        let category = EventCategory(builtIn: .important)

        // Then
        #expect(category.name.isEmpty)
        #expect(category.displayName == BuiltInCategory.important.displayName)
    }

    @Test
    func displayNameWhenCustomThenIsTheStoredName() {
        // Given / When
        let category = EventCategory(name: "Travel")

        // Then
        #expect(category.displayName == "Travel")
        #expect(category.isBuiltIn == false)
    }
}
