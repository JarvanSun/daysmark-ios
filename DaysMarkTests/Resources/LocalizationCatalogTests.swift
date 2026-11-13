//
//  LocalizationCatalogTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation
import Testing

struct LocalizationCatalogTests {
    let pluralCategories: [String: Set<String>] = [
        "en": ["one", "other"],
        "de": ["one", "other"],
        "zh-Hans": ["other"],
        "ja": ["other"],
        "ko": ["other"],
    ]

    @Test(
        arguments: [
            "DaysMark/Resources/Localizable.xcstrings",
            "DaysMark/Resources/AppShortcuts.xcstrings",
            "DaysMark/Resources/InfoPlist.xcstrings",
            "DaysMarkWidget/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/DaysMarkCore/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/DesignSystem/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/EventsFeature/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/OnboardingFeature/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/SettingsFeature/Resources/Localizable.xcstrings",
        ],
        ["en", "de", "zh-Hans", "ja", "ko"]
    )
    func catalogThenEveryKeyHasAValue(path: String, language: String) throws {
        // Given
        let catalog = try LocalizationCatalog(contentsOf: url(of: path))

        // When
        let keys = catalog.keysMissingValue(in: language)

        // Then
        #expect(keys.isEmpty, "Missing \(language) in \(path): \(keys)")
    }

    @Test(
        arguments: [
            "DaysMark/Resources/Localizable.xcstrings",
            "DaysMarkWidget/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/DaysMarkCore/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/DesignSystem/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/EventsFeature/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/OnboardingFeature/Resources/Localizable.xcstrings",
            "DaysMarkKit/Sources/SettingsFeature/Resources/Localizable.xcstrings",
        ],
        ["en", "de", "zh-Hans", "ja", "ko"]
    )
    func catalogThenPluralsHaveTheCategoriesOfTheirLanguage(path: String, language: String) throws {
        // Given
        let catalog = try LocalizationCatalog(contentsOf: url(of: path))
        let categories = try #require(pluralCategories[language])

        // When
        let keys = catalog.keysWithPluralCategories(otherThan: categories, in: language)

        // Then
        #expect(keys.isEmpty, "Wrong plural categories in \(language), \(path): \(keys)")
    }

    @Test func bundlesThenShipEveryLanguage() throws {
        // Given
        let plugIns = try #require(Bundle.main.builtInPlugInsURL)
        let widget = try #require(
            Bundle(url: plugIns.appending(path: "DaysMarkWidgetExtension.appex"))
        )

        // Then
        #expect(Set(Bundle.main.localizations).isSuperset(of: pluralCategories.keys))
        #expect(Set(widget.localizations).isSuperset(of: pluralCategories.keys))
    }

    @Test(arguments: [
        "DaysMarkCore", "DesignSystem", "EventsFeature", "OnboardingFeature", "SettingsFeature",
    ])
    func packageBundleThenShipsEveryLanguage(target: String) throws {
        // Given
        let url = try #require(
            Bundle.main.url(forResource: "DaysMarkKit_\(target)", withExtension: "bundle")
        )
        let bundle = try #require(Bundle(url: url))

        // Then
        #expect(Set(bundle.localizations).isSuperset(of: pluralCategories.keys))
    }

    @Test(arguments: [
        "DaysMark/Resources/Localizable.xcstrings",
        "DaysMarkWidget/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/DaysMarkCore/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/DesignSystem/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/EventsFeature/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/OnboardingFeature/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/SettingsFeature/Resources/Localizable.xcstrings",
    ])
    func catalogThenEveryKeyIsSemantic(path: String) throws {
        // Given
        let catalog = try LocalizationCatalog(contentsOf: url(of: path))

        // Then
        #expect(
            catalog.keysNotSemantic.isEmpty,
            "Not semantic in \(path): \(catalog.keysNotSemantic)"
        )
    }

    @Test(arguments: [
        "DaysMark/Resources/Localizable.xcstrings",
        "DaysMark/Resources/AppShortcuts.xcstrings",
        "DaysMark/Resources/InfoPlist.xcstrings",
        "DaysMarkWidget/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/DaysMarkCore/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/DesignSystem/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/EventsFeature/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/OnboardingFeature/Resources/Localizable.xcstrings",
        "DaysMarkKit/Sources/SettingsFeature/Resources/Localizable.xcstrings",
    ])
    func catalogThenEveryKeyHasAComment(path: String) throws {
        // Given
        let catalog = try LocalizationCatalog(contentsOf: url(of: path))

        // Then
        #expect(
            catalog.keysWithoutComment.isEmpty,
            "No comment in \(path): \(catalog.keysWithoutComment)"
        )
    }

    private func url(of path: String) -> URL {
        URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: path)
    }
}
