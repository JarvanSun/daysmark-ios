//
//  EventErrorTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import TestSupport
import Testing

@testable import DaysMarkCore

struct EventErrorTests {
    @Test(arguments: [EventError.emptyTitle, .eventUnavailable, .localStoreUnavailable])
    func initWhenTheErrorIsAnEventErrorThenKeepsIt(error: EventError) {
        #expect(EventError(error) == error)
    }

    @Test
    func initWhenTheErrorComesFromElsewhereThenIsAStoreFailure() {
        #expect(EventError(MockError()) == .storeFailure)
        #expect(EventError(CategoryError.emptyName) == .storeFailure)
    }
}
