//
//  EventsRouterTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import SunUserInterface
import Testing

@testable import EventsFeature

struct EventsRouterTests {
    @Test func showDetailThenPushesDetailOnce() {
        // Given
        let router = makeRouter()

        // When
        router.showDetail(for: .mockActive)
        router.showDetail(for: .mockActive)

        // Then
        #expect(router.path == [.detail(.mockActive, fromFocus: false)])
    }

    @Test func showDetailWhenOpenedFromFocusThenIsNotPushedAgain() {
        // Given
        let router = makeRouter()
        router.showDetailFromFocus(for: .mockActive)

        // When
        router.showDetail(for: .mockActive)

        // Then
        #expect(router.path == [.detail(.mockActive, fromFocus: true)])
    }

    @Test func showSettingsThenPushesEveryPage() {
        // Given
        let router = makeRouter()
        let pages: [SettingsPage] = [
            .widgets, .root, .widgets, .recentlyDeleted(highlighting: nil),
        ]

        // When
        for page in pages {
            router.showSettings(page)
        }

        // Then
        #expect(router.path == pages.map(EventsDestination.settings))
    }

    @Test func showDetailInSplitViewThenReplacesTheDetailColumn() {
        // Given
        let router = makeRouter()
        let first = UUID()
        let second = UUID()
        router.showsSplitView = true
        router.showDetail(for: first)
        router.detailPath = [.settings(.root)]

        // When
        router.showDetail(for: second)

        // Then
        #expect(router.path == [.detail(second, fromFocus: false)])
        #expect(router.selectedEventID == second)
    }

    @Test func showSettingsInSplitViewThenSelectsSettings() {
        // Given
        let router = makeRouter()
        router.showsSplitView = true
        router.showDetail(for: .mockActive)

        // When
        router.showSettings(.root)

        // Then
        #expect(router.path == [.settings(.root)])
        #expect(router.selectedEventID == nil)
    }

    @Test func detailPathThenHoldsWhatFollowsTheSelection() {
        // Given
        let router = makeRouter()
        router.path = [.detail(.mockActive, fromFocus: false), .settings(.root)]

        // When
        router.detailPath = [.settings(.root), .settings(.widgets)]

        // Then
        #expect(router.selection == .detail(.mockActive, fromFocus: false))
        #expect(router.detailPath == [.settings(.root), .settings(.widgets)])
    }

    @Test func detailPathWithoutASelectionThenStaysEmpty() {
        // Given
        let router = makeRouter()

        // When
        router.detailPath = [.settings(.root)]

        // Then
        #expect(router.path.isEmpty)
    }

    @Test func showEditorThenPresentsOneSheetAtATime() {
        // Given
        let router = makeRouter()

        // When
        router.showEditor(for: .new(categoryID: BuiltInCategory.birthday.id))
        let first = router.presentation?.destination
        router.showEditor(for: .existing(.mockActive))

        // Then
        #expect(first == .editor(.new(categoryID: BuiltInCategory.birthday.id)))
        #expect(router.presentation?.destination == .editor(.existing(.mockActive)))
        #expect(router.presentation?.style == .sheet)
        #expect(router.editorViewModel != nil)
    }

    @Test func showSharingThenPresentsTheShareSheet() {
        // Given
        let router = makeRouter()

        // When
        router.showSharing(for: .mockActive)

        // Then
        #expect(router.presentation?.destination == .sharing(.mockActive))
        #expect(router.isPresentingSheet)
    }

    @Test func showSpecialNodesThenPushesInsideTheEditorSheet() {
        // Given
        let router = makeRouter()
        router.showEditor(for: .existing(.mockActive))

        // When
        router.showSpecialNodes()

        // Then
        #expect(router.presentation?.navigation.path == [.specialNodes])
        #expect(router.path.isEmpty)
    }

    @Test func dismissSheetThenClosesTheSheetAndReleasesTheEditor() {
        // Given
        let router = makeRouter()
        router.showEditor(for: .existing(.mockActive))

        // When
        router.dismissSheet()

        // Then
        #expect(router.presentation == nil)
        #expect(router.editorViewModel == nil)
        #expect(!router.isPresentingSheet)
    }

    @Test func closeDetailThenRemovesThatEventFromThePath() {
        // Given
        let router = makeRouter()
        router.showDetailFromFocus(for: .mockActive)

        // When
        router.closeDetail(for: .mockActive)

        // Then
        #expect(router.path.isEmpty)
    }

    @Test func showHomeThenReturnsToTheRoot() {
        // Given
        let router = makeRouter()
        router.path = [.settings(.root), .settings(.widgets)]

        // When
        router.showHome()

        // Then
        #expect(router.path.isEmpty)
    }

    @Test func openDetailOnAColdStartThenReplacesThePath() {
        // Given
        let router = makeRouter()
        router.path = [.settings(.root)]

        // When
        router.open(.detail(.mockActive, fromFocus: false), context: .coldStart)

        // Then
        #expect(router.path == [.detail(.mockActive, fromFocus: false)])
        #expect(router.presentation == nil)
    }

    @Test func openDetailInAnActiveSessionThenAppendsItOnce() {
        // Given
        let router = makeRouter()
        router.path = [.settings(.root)]

        // When
        router.open(.detail(.mockActive, fromFocus: false), context: .activeSession)
        router.open(.detail(.mockActive, fromFocus: false), context: .activeSession)

        // Then
        #expect(router.path == [.settings(.root), .detail(.mockActive, fromFocus: false)])
    }

    @Test func openDetailWhenAlreadyOpenedFromFocusThenKeepsThePath() {
        // Given
        let router = makeRouter()
        router.showDetailFromFocus(for: .mockActive)

        // When
        router.open(.detail(.mockActive, fromFocus: false), context: .activeSession)

        // Then
        #expect(router.path == [.detail(.mockActive, fromFocus: true)])
    }

    @Test func openEditorOnAColdStartThenPresentsItOverHome() {
        // Given
        let router = makeRouter()
        router.path = [.settings(.root)]

        // When
        router.open(.editor(.existing(.mockOther)), context: .coldStart)

        // Then
        #expect(router.path.isEmpty)
        #expect(router.presentation?.destination == .editor(.existing(.mockOther)))
        #expect(router.editorViewModel != nil)
    }

    @Test func openEditorInAnActiveSessionThenKeepsThePath() {
        // Given
        let router = makeRouter()
        router.path = [.settings(.root)]

        // When
        router.open(.editor(.existing(.mockOther)), context: .activeSession)

        // Then
        #expect(router.path == [.settings(.root)])
        #expect(router.presentation?.destination == .editor(.existing(.mockOther)))
    }

    @Test func openRecentlyDeletedOnAColdStartThenShowsTheHighlightedEvent() {
        // Given
        let router = makeRouter()
        let recovery = EventsDestination.settings(
            .recentlyDeleted(highlighting: .mockDeleted)
        )

        // When
        router.open(recovery, context: .coldStart)

        // Then
        #expect(router.path == [recovery])
    }

    @Test func openRecentlyDeletedInAnActiveSessionThenAppendsItOnce() {
        // Given
        let router = makeRouter()
        let recovery = EventsDestination.settings(
            .recentlyDeleted(highlighting: .mockDeleted)
        )
        router.path = [.settings(.root)]

        // When
        router.open(recovery, context: .activeSession)
        router.open(recovery, context: .activeSession)

        // Then
        #expect(router.path == [.settings(.root), recovery])
    }

    @Test(arguments: [
        EventsDestination.editor(.existing(.mockMissing)),
        .editor(.new(categoryID: BuiltInCategory.important.id)),
        .sharing(.mockMissing),
    ])
    func openWhileASheetIsUpThenKeepsTheSheetAndThePath(sheet: EventsDestination) {
        // Given
        let router = makeRouter()
        router.path = [.settings(.root)]
        router.presentation = .init(destination: sheet, style: .sheet)

        // When
        router.open(.detail(.mockActive, fromFocus: false), context: .activeSession)
        router.open(.editor(.existing(.mockOther)), context: .activeSession)
        router.open(.settings(.widgets), context: .activeSession)

        // Then
        #expect(router.presentation?.destination == sheet)
        #expect(router.path == [.settings(.root)])
    }

    @Test func openTheEventBeingEditedThenLeavesTheDraftAlone() {
        // Given
        let router = makeRouter()
        router.showEditor(for: .existing(.mockActive))
        let editor = router.editorViewModel

        // When
        router.open(.detail(.mockActive, fromFocus: false), context: .activeSession)
        router.open(.editor(.existing(.mockActive)), context: .activeSession)

        // Then
        #expect(router.presentation?.destination == .editor(.existing(.mockActive)))
        #expect(router.editorViewModel === editor)
        #expect(router.path.isEmpty)
    }

    @Test func showRequestedDetailWithAnEmptyPathThenShowsDetail() {
        // Given
        let router = makeRouter()

        // When
        router.showRequestedDetail(for: .mockActive)

        // Then
        #expect(router.path == [.detail(.mockActive, fromFocus: false)])
    }

    @Test func showRequestedSettingsBehindAScreenThenAppends() {
        // Given
        let router = makeRouter()
        router.showSettings(.root)

        // When
        router.showRequestedSettings(.widgets)

        // Then
        #expect(router.path == [.settings(.root), .settings(.widgets)])
    }

    private func makeRouter() -> EventsRouter {
        .init(dependencies: .mock())
    }
}
