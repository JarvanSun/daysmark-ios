//
//  CategoriesIssueTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Testing

@testable import SettingsFeature

struct CategoriesIssueTests {
    @Test(arguments: [
        (CategoryError.emptyName, CategoriesIssue.emptyName),
        (.cannotDeleteBuiltIn, .builtInCategory),
        (.categoryUnavailable, .categoryUnavailable),
    ])
    func initThenMapsEveryCategoryError(error: CategoryError, expected: CategoriesIssue) {
        // Given / When
        let issue = CategoriesIssue(error)

        // Then
        #expect(issue == expected)
    }

    @Test func initWhenTheStoreFailedThenIsUnknown() {
        // Given / When
        let issue = CategoriesIssue(.storeFailure)

        // Then
        #expect(issue == .unknown)
    }

    @Test(arguments: [
        (CategoriesIssue.emptyName, "settings.categories.issue.emptyName" as String?),
        (.builtInCategory, "settings.categories.issue.builtIn"),
        (.categoryUnavailable, "settings.categories.issue.unavailable"),
        (.unknown, nil),
    ])
    func messageThenExplainsOnlyAKnownIssue(issue: CategoriesIssue, key: String?) {
        #expect(issue.message?.key == key)
    }

    @Test func titleThenSaysSavingFailed() {
        #expect(CategoriesIssue.unknown.title.key == "settings.categories.issue.title")
    }
}
