//
//  EventsDestinationTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import EventsFeature

struct EventsDestinationTests {
    @Test func showsSameScreenThenIgnoresWhereDetailWasOpenedFrom() {
        // Given
        let fromRow = EventsDestination.detail(.mockActive, fromFocus: false)
        let fromFocus = EventsDestination.detail(.mockActive, fromFocus: true)

        // Then
        #expect(fromRow.shows(sameScreenAs: fromFocus))
        #expect(fromRow != fromFocus)
    }

    @Test func showsSameScreenThenTellsEventsAndPagesApart() {
        // Given
        let detail = EventsDestination.detail(.mockActive, fromFocus: false)

        // Then
        #expect(!detail.shows(sameScreenAs: .detail(.mockDeleted, fromFocus: false)))
        #expect(!detail.shows(sameScreenAs: .settings(.root)))
        #expect(EventsDestination.settings(.root).shows(sameScreenAs: .settings(.root)))
    }

    @Test func editorTargetsThenDifferByWhatTheyEdit() {
        // Given
        let birthday = EditorTarget.new(categoryID: BuiltInCategory.birthday.id)
        let anniversary = EditorTarget.new(categoryID: BuiltInCategory.anniversary.id)

        // Then
        #expect(birthday != anniversary)
        #expect(EditorTarget.existing(.mockActive) != .existing(.mockDeleted))
        #expect(birthday.eventID == nil)
        #expect(EditorTarget.existing(.mockActive).eventID == .mockActive)
    }
}
