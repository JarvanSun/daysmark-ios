//
//  ImportIssueTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import SettingsFeature

struct ImportIssueTests {
    @Test(arguments: [
        (ImportError.permissionDenied, ImportIssue.permissionDenied),
        (.localStoreUnavailable, .storageUnavailable),
    ])
    func initThenMapsEveryNamedImportError(error: ImportError, expected: ImportIssue) {
        // Given / When
        let issue = ImportIssue(error)

        // Then
        #expect(issue == expected)
    }

    @Test func initWhenAStoreFailsThenIsUnknown() {
        // Given / When
        let issue = ImportIssue(.storeFailure)

        // Then
        #expect(issue == .unknown)
    }

    @Test(arguments: [
        (
            ImportIssue.permissionDenied,
            "settings.import.issue.accessDenied" as String?
        ),
        (.storageUnavailable, "settings.import.issue.storageUnavailable"),
        (.unknown, nil),
    ])
    func messageThenExplainsOnlyAKnownIssue(issue: ImportIssue, key: String?) {
        #expect(issue.message?.key == key)
    }

    @Test func titleThenSaysImportIsUnavailable() {
        #expect(ImportIssue.unknown.title.key == "settings.import.issue.title")
    }
}
