//
//  EventDraftPreviewTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

struct EventDraftPreviewTests {
    @Test
    func previewEventThenCarriesTheDraftsDatesWithoutBeingStored() throws {
        // Given
        var draft = EventDraft.mock("  Trip  ", on: .mock(2030, 1, 10))
        draft.endDate = .mock(2030, 1, 12)
        draft.repeatRule = .yearly

        // When
        let event = try #require(draft.previewEvent(at: .mockNow))

        // Then
        #expect(event.title == "Trip")
        #expect(event.startDateSpecification == draft.targetDateSpecification)
        #expect(event.rangeCalendarDaySpan == 2)
        #expect(event.rangeDurationSeconds == nil)
        #expect(event.repeatRule == .yearly)
        #expect(event.modelContext == nil)
    }

    @Test
    func previewEventWhenTimedThenMeasuresTheRangeAsADuration() throws {
        // Given
        var draft = EventDraft.mock("Call", on: .mock(2030, 1, 10, hour: 9))
        draft.timeSemantics = .floatingLocalTime
        draft.endDate = .mock(2030, 1, 10, hour: 11)

        // When
        let event = try #require(draft.previewEvent(at: .mockNow))

        // Then
        #expect(event.rangeCalendarDaySpan == nil)
        #expect(event.rangeDurationSeconds == 7_200)
        #expect(event.targetHour == 9)
    }
}
