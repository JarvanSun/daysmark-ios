//
//  CategoryErrorTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import TestSupport
import Testing

@testable import DaysMarkCore

struct CategoryErrorTests {
    @Test(arguments: [CategoryError.emptyName, .cannotDeleteBuiltIn, .categoryUnavailable])
    func initWhenTheErrorIsACategoryErrorThenKeepsIt(error: CategoryError) {
        #expect(CategoryError(error) == error)
    }

    @Test
    func initWhenTheErrorComesFromElsewhereThenIsAStoreFailure() {
        #expect(CategoryError(MockError()) == .storeFailure)
    }
}
