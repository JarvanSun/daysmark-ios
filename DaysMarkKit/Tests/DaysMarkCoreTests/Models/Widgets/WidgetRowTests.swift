//
//  WidgetRowTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct WidgetRowTests {
    @Test(arguments: [("Sep 10, 2026", "Trip, in 6 days, Sep 10, 2026"), (nil, "Trip, in 6 days")])
    func accessibilityLabelThenReadsTheTitleThePhraseAndTheDate(dateText: String?, expected: String)
    {
        // Given
        let row = WidgetRow(
            id: UUID(),
            title: "Trip",
            phrase: RelativeTimePhrase(DayCount(days: 6, direction: .upcoming)),
            dateText: dateText,
            direction: .upcoming
        )

        // Then
        #expect(row.accessibilityLabel == expected)
    }
}
