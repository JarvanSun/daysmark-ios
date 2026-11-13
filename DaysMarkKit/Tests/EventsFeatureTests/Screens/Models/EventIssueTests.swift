//
//  EventIssueTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import EventsFeature

struct EventIssueTests {
    @Test(arguments: [
        (EventError.emptyTitle, EventIssue.emptyTitle),
        (.invalidDraft, .invalidDate),
        (.permanentlyDeleted, .permanentlyDeleted),
        (.inRecentlyDeleted, .inRecentlyDeleted),
        (.localStoreUnavailable, .storageUnavailable),
        (.eventUnavailable, .actionFailed),
    ])
    func initThenMapsEveryEventError(error: EventError, expected: EventIssue) {
        #expect(EventIssue(error) == expected)
    }

    @Test func initWhenTheStoreFailedThenIsAFailedAction() {
        #expect(EventIssue(.storeFailure) == .actionFailed)
    }

    @Test func messageForAFailedActionThenIsLeftToTheTitle() {
        #expect(EventIssue.actionFailed.message == nil)
        #expect(EventIssue.actionFailed.title.key == "event.issue.title")
    }

    @Test(arguments: [
        (EventIssue.emptyTitle, "event.issue.emptyTitle"),
        (.invalidDate, "event.issue.invalidDate"),
        (.permanentlyDeleted, "event.issue.permanentlyDeleted"),
        (.inRecentlyDeleted, "event.issue.inRecentlyDeleted"),
        (.storageUnavailable, "event.issue.storageUnavailable"),
        (.batchDeleteFailed(count: 2), "event.issue.batchDeleteFailed %lld"),
    ])
    func messageThenExplainsTheIssue(issue: EventIssue, key: String) {
        #expect(issue.message?.key == key)
    }
}
