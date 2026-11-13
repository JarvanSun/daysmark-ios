//
//  DetailContentTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import EventsFeature

struct DetailContentTests {
    @Test func eventThenCountsTheStoredEventAtTheGivenMoment() {
        // Given
        let event = CountdownEvent.mock(id: .mockActive, day: 22)

        // When
        let content = makeContent(events: [event])

        // Then
        #expect(content.event?.id == .mockActive)
        #expect(content.event?.counted.dayCount == DayCount(days: 12, direction: .upcoming))
        #expect(!content.isDeleted)
        #expect(content.canSwitchUnit)
        #expect(content.nextChange == .mock(2030, 9, 11))
    }

    @Test func eventWhenTheRecordIsGoneThenIsMissingAndDeleted() {
        // Given / When
        let content = makeContent(events: [])

        // Then
        #expect(content.event == nil)
        #expect(content.isDeleted)
        #expect(!content.canSwitchUnit)
        #expect(content.nextChange == nil)
    }

    @Test func canSwitchUnitOnTheEventsDayThenIsFalse() {
        // Given / When
        let content = makeContent(events: [.mock(id: .mockActive, day: 10)])

        // Then
        #expect(!content.canSwitchUnit)
    }

    @Test func eventWhenAnotherOrADeletedRecordIsStoredThenIsMissing() {
        // Given / When
        let content = makeContent(events: [.mock(id: .mockOther), .mockDeleted(id: .mockActive)])

        // Then
        #expect(content.event == nil)
    }

    @Test(arguments: [(UUID.mockActive, PinAction.unpin), (.mockDeleted, .pin(.mockActive))])
    func pinActionThenClearsOnlyWhenThisEventIsPinned(pinnedID: UUID, expected: PinAction) {
        // Given / When
        let content = makeContent(events: [.mock(id: .mockActive)], pinnedEventID: pinnedID)

        // Then
        #expect(content.pinAction == expected)
    }

    @Test func tickerTargetThenIsTheOccurrenceUnlessItIsTheEventsDay() {
        // Given / When
        let upcoming = makeContent(events: [.mock(id: .mockActive, day: 22)])
        let today = makeContent(events: [.mock(id: .mockActive, day: 10)])

        // Then
        #expect(upcoming.tickerTarget == upcoming.event?.counted.resolvedOccurrenceDate)
        #expect(upcoming.tickerTarget != nil)
        #expect(today.tickerTarget == nil)
    }

    private func makeContent(
        events: [CountdownEvent],
        pinnedEventID: UUID? = nil
    ) -> DetailContent {
        DetailData(events: events, pinnedEventID: pinnedEventID)
            .content(of: .mockActive, unit: .days, at: .mock())
    }
}
