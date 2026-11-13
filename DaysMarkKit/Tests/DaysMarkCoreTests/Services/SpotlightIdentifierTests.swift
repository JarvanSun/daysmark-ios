//
//  SpotlightIdentifierTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import DaysMarkCore

struct SpotlightIdentifierTests {
    @Test func rawValuesThenKeepTheirShippedValues() {
        #expect(SpotlightIdentifier.index.rawValue == "ImportantDates")
        #expect(SpotlightIdentifier.domain.rawValue == "com.example.daysmark.events")
    }
}
