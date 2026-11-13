//
//  WidgetKindTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import DaysMarkCore

struct WidgetKindTests {
    @Test func rawValuesThenKeepTheirShippedValues() {
        #expect(WidgetKind.focus.rawValue == "HeroCountdownWidget")
        #expect(WidgetKind.list.rawValue == "ImportantDatesListWidget")
    }
}
