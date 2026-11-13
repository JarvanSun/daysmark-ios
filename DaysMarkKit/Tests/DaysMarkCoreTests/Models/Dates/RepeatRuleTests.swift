//
//  RepeatRuleTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/31.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct RepeatRuleTests {

    @Test
    func displayNameThenIsDistinctForEveryRule() {
        let labels = RepeatRule.allCases.map(\.displayName)

        #expect(Set(labels).count == labels.count)
        #expect(labels.allSatisfy { !$0.isEmpty })
    }

    @Test(arguments: [
        (RepeatRule.yearly, [RepeatRule.never, .monthly, .yearly]),
        (.monthlyLastDay, [.never, .monthly, .yearly, .monthlyLastDay]),
    ])
    func editorCasesThenOfferTheCommonRulesAndTheCurrentOne(
        current: RepeatRule,
        expected: [RepeatRule]
    ) {
        #expect(current.editorCases == expected)
    }
}

struct LegacyRepeatFieldsTests {

    @Test
    func repeatUnitWhenNothingIsStoredThenIsYear() {
        let event = event()
        event.storedRepeatUnit = nil

        #expect(event.repeatUnit == .year)
    }

    @Test
    func repeatIntervalWhenNothingIsStoredThenIsOne() {
        let event = event()
        event.storedRepeatInterval = nil

        #expect(event.repeatInterval == 1)
    }

    @Test
    func repeatIntervalWhenTheStoredValueIsOutOfRangeThenIsClamped() {
        let event = event()
        event.storedRepeatInterval = 0
        #expect(event.repeatInterval == RepeatRule.custom.intervalRange.lowerBound)

        event.storedRepeatInterval = 9_999
        #expect(event.repeatInterval == RepeatRule.custom.intervalRange.upperBound)
    }

    private func event() -> CountdownEvent {
        CountdownEvent.mock(title: "e", year: 2026, month: 9, day: 10)
    }
}
