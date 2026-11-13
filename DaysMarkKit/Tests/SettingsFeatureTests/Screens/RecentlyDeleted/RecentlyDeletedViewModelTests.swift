//
//  RecentlyDeletedViewModelTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/10/07.
//

import DaysMarkCore
import Foundation
import TestSupport
import Testing

@testable import SettingsFeature

struct RecentlyDeletedViewModelTests {
    @Test func reloadThenListsTheMostRecentlyDeletedEventFirst() {
        // Given
        let older = CountdownEvent.mock(deletedAt: .mockNow.addingTimeInterval(-86_400))
        let newer = CountdownEvent.mock(deletedAt: .mockNow)
        let repository = EventRepositorySpy()
        repository.storedEvents = [older, .mock(), newer]
        let viewModel = makeViewModel(repository: repository)

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.content.rows.map(\.id) == [newer.id, older.id])
        #expect(viewModel.issue == nil)
    }

    @Test func reloadWhenReadingFailsThenShowsTheIssue() {
        // Given
        let repository = EventRepositorySpy()
        repository.readError = .localStoreUnavailable
        let viewModel = makeViewModel(repository: repository)

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.issue == .storageUnavailable)
    }

    @Test func observeStoreThenLoadsTheStoredEvents() async {
        // Given
        let deleted = CountdownEvent.mock(deletedAt: .mockNow)
        let repository = EventRepositorySpy()
        repository.storedEvents = [deleted]
        let viewModel = makeViewModel(repository: repository)

        // When
        await viewModel.observeStore()

        // Then
        #expect(viewModel.content.rows.map(\.id) == [deleted.id])
    }

    @Test func deleteSelectionPermanentlyThenDeletesOnlySelectedDeletedEvents() {
        // Given
        let deleted = CountdownEvent.mock(deletedAt: .mockNow)
        let otherDeleted = CountdownEvent.mock(deletedAt: .mockNow)
        let active = CountdownEvent.mock()
        let repository = EventRepositorySpy()
        let viewModel = makeViewModel(showing: [deleted, otherDeleted, active], in: repository)
        viewModel.startSelecting()
        viewModel.selection = [deleted.id, active.id]

        // When
        viewModel.deleteSelectionPermanently()

        // Then
        #expect(repository.permanentlyDeletedIDs == [deleted.id])
        #expect(viewModel.selection.isEmpty)
        #expect(!viewModel.isSelecting)
        #expect(viewModel.issue == nil)
    }

    @Test func deleteSelectionPermanentlyWhenSomeFailThenKeepsThemSelectedAndCountsThem() {
        // Given
        let succeeds = CountdownEvent.mock(deletedAt: .mockNow)
        let fails = CountdownEvent.mock(deletedAt: .mockNow)
        let repository = EventRepositorySpy(failingIDs: [fails.id], error: .storeFailure)
        let viewModel = makeViewModel(showing: [succeeds, fails], in: repository)
        viewModel.startSelecting()
        viewModel.selection = [succeeds.id, fails.id]

        // When
        viewModel.deleteSelectionPermanently()

        // Then
        #expect(Set(repository.permanentlyDeletedIDs) == [succeeds.id, fails.id])
        #expect(viewModel.selection == [fails.id])
        #expect(viewModel.isSelecting)
        #expect(viewModel.issue == .batchFailed(count: 1))
    }

    @Test func deleteSelectionPermanentlyWithoutASelectionThenDeletesNothing() {
        // Given
        let repository = EventRepositorySpy()
        let viewModel = makeViewModel(
            showing: [.mock(deletedAt: .mockNow)],
            in: repository
        )
        viewModel.startSelecting()

        // When
        viewModel.deleteSelectionPermanently()

        // Then
        #expect(repository.permanentlyDeletedIDs.isEmpty)
        #expect(!viewModel.isSelecting)
    }

    @Test func deletePermanentlyThenDeletesThatEvent() {
        // Given
        let deleted = CountdownEvent.mock(deletedAt: .mockNow)
        let repository = EventRepositorySpy()
        let viewModel = makeViewModel(showing: [deleted], in: repository)

        // When
        viewModel.deletePermanently(deleted.id)

        // Then
        #expect(repository.permanentlyDeletedIDs == [deleted.id])
        #expect(viewModel.issue == nil)
    }

    @Test func deletePermanentlyWhenItFailsThenShowsTheIssue() {
        // Given
        let deleted = CountdownEvent.mock(deletedAt: .mockNow)
        let viewModel = makeViewModel(
            showing: [deleted],
            in: EventRepositorySpy(failingIDs: [deleted.id], error: .localStoreUnavailable)
        )

        // When
        viewModel.deletePermanently(deleted.id)

        // Then
        #expect(viewModel.issue == .storageUnavailable)
    }

    @Test func restoreThenRestoresThatEvent() {
        // Given
        let repository = EventRepositorySpy()
        let viewModel = makeViewModel(repository: repository)
        let id = UUID()

        // When
        viewModel.restore(id)

        // Then
        #expect(repository.restoredIDs == [id])
        #expect(viewModel.issue == nil)
    }

    @Test func restoreWhenItFailsThenShowsTheIssue() {
        // Given
        let id = UUID()
        let viewModel = makeViewModel(
            repository: EventRepositorySpy(failingIDs: [id], error: .storeFailure)
        )

        // When
        viewModel.restore(id)

        // Then
        #expect(viewModel.issue == .actionFailed)
    }

    @Test func acknowledgeIssueThenClearsTheIssue() {
        // Given
        let id = UUID()
        let viewModel = makeViewModel(
            repository: EventRepositorySpy(failingIDs: [id], error: .storeFailure)
        )
        viewModel.restore(id)

        // When
        viewModel.acknowledgeIssue()

        // Then
        #expect(viewModel.issue == nil)
    }

    @Test func selectAllThenSelectsEveryDeletedEvent() {
        // Given
        let deleted = [CountdownEvent.mock(deletedAt: .mockNow), .mock(deletedAt: .mockNow)]
        let viewModel = makeViewModel(showing: deleted + [.mock()], in: EventRepositorySpy())
        viewModel.startSelecting()

        // When
        viewModel.selectAll()

        // Then
        #expect(viewModel.selection == Set(deleted.map(\.id)))
    }

    @Test func finishSelectingThenClearsTheSelection() {
        // Given
        let viewModel = makeViewModel()
        viewModel.startSelecting()
        viewModel.selection = [UUID()]

        // When
        viewModel.finishSelecting()

        // Then
        #expect(!viewModel.isSelecting)
        #expect(viewModel.selection.isEmpty)
    }

    @Test func reloadThenSkipsEventsThatAreBeingErased() {
        // Given
        let deleted = CountdownEvent.mock(deletedAt: .mockNow)
        let erasing = CountdownEvent.mock(
            deletedAt: .mockNow,
            permanentDeletionRequestedAt: .mockNow
        )
        let viewModel = makeViewModel(showing: [deleted, erasing], in: EventRepositorySpy())

        // When
        let rows = viewModel.content.rows

        // Then
        #expect(rows.map(\.id) == [deleted.id])
    }

    @Test(arguments: [
        (false, "settings.recentlyDeleted.title"),
        (true, "settings.recentlyDeleted.selection.count %lld"),
    ])
    func titleThenCountsTheSelectionWhileSelecting(isSelecting: Bool, key: String) {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.isSelecting = isSelecting

        // Then
        #expect(viewModel.title.key == key)
    }

    @Test func contentThenHighlightsTheEventTheScreenWasOpenedFor() {
        // Given
        let deleted = CountdownEvent.mock(deletedAt: .mockNow)
        let repository = EventRepositorySpy()
        repository.storedEvents = [deleted, .mock(deletedAt: .mockNow)]
        let viewModel = makeViewModel(highlightedEventID: deleted.id, repository: repository)
        viewModel.reload()

        // When
        let content = viewModel.content

        // Then
        #expect(content.rows.map(\.isHighlighted) == [true, false])
    }
}

private extension RecentlyDeletedViewModelTests {
    func makeViewModel(
        highlightedEventID: CountdownEvent.ID? = nil,
        repository: EventRepositorySpy = .init()
    ) -> RecentlyDeletedViewModel {
        RecentlyDeletedViewModel(highlightedEventID: highlightedEventID, repository: repository)
    }

    func makeViewModel(
        showing events: [CountdownEvent],
        in repository: EventRepositorySpy
    ) -> RecentlyDeletedViewModel {
        repository.storedEvents = events
        let viewModel = makeViewModel(repository: repository)
        viewModel.reload()

        return viewModel
    }
}
