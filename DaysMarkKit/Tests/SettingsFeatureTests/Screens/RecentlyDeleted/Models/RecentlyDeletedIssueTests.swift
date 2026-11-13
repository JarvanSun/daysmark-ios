//
//  RecentlyDeletedIssueTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import SettingsFeature

struct RecentlyDeletedIssueTests {
    @Test(arguments: [
        (EventError.localStoreUnavailable, RecentlyDeletedIssue.storageUnavailable),
        (.eventUnavailable, .actionFailed),
        (.permanentlyDeleted, .actionFailed),
    ])
    func initThenMapsEventErrors(error: EventError, expected: RecentlyDeletedIssue) {
        // Given / When
        let issue = RecentlyDeletedIssue(error)

        // Then
        #expect(issue == expected)
    }

    @Test func initWhenTheStoreFailedThenSaysTheActionFailed() {
        // Given / When
        let issue = RecentlyDeletedIssue(.storeFailure)

        // Then
        #expect(issue == .actionFailed)
    }

    @Test(arguments: [
        (RecentlyDeletedIssue.actionFailed, nil as String?),
        (.storageUnavailable, "settings.recentlyDeleted.issue.storageUnavailable"),
        (.batchFailed(count: 2), "settings.recentlyDeleted.issue.deleteFailed %lld"),
    ])
    func messageThenExplainsWhatFailed(issue: RecentlyDeletedIssue, key: String?) {
        #expect(issue.message?.key == key)
    }

    @Test func titleThenSaysTheActionFailed() {
        #expect(
            RecentlyDeletedIssue.actionFailed.title.key == "settings.recentlyDeleted.issue.title"
        )
    }
}
