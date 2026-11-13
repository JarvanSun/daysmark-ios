//
//  ImportedDateTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct ImportedDateTests {
    @Test
    func formattedDateThenShowsTheDayInTheSourceTimeZone() {
        // Given
        let item = ImportedDate.mock(
            date: .mock(2027, 1, 2, hour: 0, in: .mockTokyo),
            timeZone: .mockTokyo
        )

        // When
        let text = item.formattedDate(locale: Locale(identifier: "en_US"))

        // Then
        #expect(text == "Jan 2, 2027")
    }

    @Test
    func dateComponentsWhenTimedThenIncludeTheTimeInTheSourceTimeZone() {
        // Given / When
        let components = ImportedDate.mockTimedCalendarEvent.dateComponents

        // Then
        #expect(components.year == 2031)
        #expect(components.month == 5)
        #expect(components.day == 4)
        #expect(components.hour == 9)
        #expect(components.minute == 30)
    }
}
