//
//  ImportantDateRepeatOptionTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Testing

@testable import DaysMark

struct ImportantDateRepeatOptionTests {
    @Test func rawValuesThenAreTheOnesShortcutsStored() {
        // Given / When / Then
        #expect(ImportantDateRepeatOption.never.rawValue == "never")
        #expect(ImportantDateRepeatOption.monthly.rawValue == "monthly")
        #expect(ImportantDateRepeatOption.yearly.rawValue == "yearly")
    }

    @Test func repeatRuleThenIsTheRuleOfTheSameName() {
        // Given / When / Then
        #expect(ImportantDateRepeatOption.never.repeatRule == .never)
        #expect(ImportantDateRepeatOption.monthly.repeatRule == .monthly)
        #expect(ImportantDateRepeatOption.yearly.repeatRule == .yearly)
    }
}
