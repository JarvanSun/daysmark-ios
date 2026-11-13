//
//  SettingsRouterTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SunUserInterface
import Testing

@testable import SettingsFeature

struct SettingsRouterTests {
    @Test func showNotificationsThenPushesNotifications() {
        // Given
        let router = makeRouter()

        // When
        router.showNotifications()

        // Then
        #expect(router.pushed == .notifications)
    }

    @Test func showCategoriesThenPushesCategories() {
        // Given
        let router = makeRouter()

        // When
        router.showCategories()

        // Then
        #expect(router.pushed == .categories)
    }

    @Test func showImportThenPushesImport() {
        // Given
        let router = makeRouter()

        // When
        router.showImport()

        // Then
        #expect(router.pushed == .importDates)
    }

    @Test func showWidgetsThenPushesTheWidgetInstructions() {
        // Given
        let router = makeRouter()

        // When
        router.showWidgets()

        // Then
        #expect(router.pushed == .widgets)
    }

    @Test func showSiriAndShortcutsThenPushesSiriAndShortcuts() {
        // Given
        let router = makeRouter()

        // When
        router.showSiriAndShortcuts()

        // Then
        #expect(router.pushed == .siriAndShortcuts)
    }

    @Test func showRecentlyDeletedThenPushesRecentlyDeletedWithoutAHighlight() {
        // Given
        let router = makeRouter()

        // When
        router.showRecentlyDeleted()

        // Then
        #expect(router.pushed == .recentlyDeleted(highlighting: nil))
    }

    @Test func showCategoryEditorThenPresentsASheetAboveTheCategories() {
        // Given
        let router = makeRouter()
        router.showCategories()

        // When
        router.showCategoryEditor(for: .new)

        // Then
        #expect(router.path == [.categories])
        #expect(router.presentation?.destination == .categoryEditor(.new))
        #expect(router.presentation?.style == .sheet)
    }

    @Test func dismissCategoryEditorThenClosesTheSheetAndStaysOnTheCategories() {
        // Given
        let router = makeRouter()
        router.showCategories()
        router.showCategoryEditor(for: .new)

        // When
        router.dismissCategoryEditor()

        // Then
        #expect(router.presentation == nil)
        #expect(router.path == [.categories])
    }

    @Test func pushedWhenClearedThenEmptiesThePath() {
        // Given
        let router = makeRouter()
        router.showImport()

        // When
        router.pushed = nil

        // Then
        #expect(router.path.isEmpty)
    }

    private func makeRouter() -> SettingsRouter {
        .init(dependencies: .mock())
    }
}
