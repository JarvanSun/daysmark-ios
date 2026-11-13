//
//  EventDetailViewModelTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import TestSupport
import Testing

@testable import EventsFeature

struct EventDetailViewModelTests {
    @Test(arguments: [false, true])
    func togglePinThenSetsOrClearsTheFocusOfTheShownEvent(wasFocus: Bool) {
        // Given
        let events = makeEvents(focus: wasFocus ? .mockActive : nil)
        let viewModel = makeViewModel(events: events)
        viewModel.reload()

        // When
        viewModel.togglePin()

        // Then
        #expect(events.selections == [wasFocus ? nil : .mockActive])
        #expect(viewModel.issue == nil)
    }

    @Test func togglePinWhenItFailsThenReportsTheIssue() {
        // Given
        let events = makeEvents()
        let viewModel = makeViewModel(events: events)
        viewModel.reload()
        events.error = .storeFailure

        // When
        viewModel.togglePin()
        let failed = viewModel.issue
        viewModel.acknowledgeIssue()

        // Then
        #expect(failed == .actionFailed)
        #expect(viewModel.issue == nil)
    }

    @Test func reloadThenShowsOnlyTheStoredEventWithItsConflicts() {
        // Given
        let version = EventConflictVersion(id: UUID(), draft: .mock(), createdAt: .mockNow)
        let events = makeEvents(versions: [version])
        events.storedEvents.append(.mock(id: .mockOther))
        let viewModel = makeViewModel(events: events)

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.content.event?.id == .mockActive)
        #expect(viewModel.content.conflictVersions == [version])
        #expect(viewModel.content.hasConflicts)
    }

    @Test func reloadWhenTheEventIsInRecentlyDeletedThenShowsItAsDeleted() {
        // Given
        let viewModel = makeViewModel(
            events: EventRepositorySpy(storedEvents: [.mockDeleted(id: .mockActive)])
        )

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.content.isDeleted)
    }

    @Test func reloadWhenTheStoreFailsThenReportsTheIssue() {
        // Given
        let viewModel = makeViewModel(events: EventRepositorySpy(readError: .storeFailure))

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.issue == .actionFailed)
    }

    @Test func keepThenResolvesWithTheChosenVersionAndClosesTheChoice() {
        // Given
        let version = EventConflictVersion(id: UUID(), draft: .mock(), createdAt: .mockNow)
        let events = makeEvents(versions: [version])
        let viewModel = makeViewModel(events: events)
        viewModel.reload()
        viewModel.chooseVersion()

        // When
        viewModel.keep(version.id)

        // Then
        #expect(
            events.resolutions
                == [EventRepositorySpy.Resolution(eventID: .mockActive, versionID: version.id)]
        )
        #expect(!viewModel.isChoosingVersion)
        #expect(viewModel.issue == nil)
    }

    @Test func keepWhenItFailsThenClosesTheChoiceAndReportsTheIssue() {
        // Given
        let version = EventConflictVersion(id: UUID(), draft: .mock(), createdAt: .mockNow)
        let events = makeEvents(versions: [version])
        let viewModel = makeViewModel(events: events)
        viewModel.reload()
        viewModel.chooseVersion()
        events.error = .inRecentlyDeleted

        // When
        viewModel.keep(version.id)

        // Then
        #expect(viewModel.issue == .inRecentlyDeleted)
        #expect(!viewModel.isChoosingVersion)
        #expect(viewModel.content.hasConflicts)
    }

    @Test func cancelChoosingVersionThenClosesTheChoice() {
        // Given
        let viewModel = makeViewModel()
        viewModel.chooseVersion()

        // When
        viewModel.cancelChoosingVersion()

        // Then
        #expect(!viewModel.isChoosingVersion)
    }

    @Test func showNextUnitThenCyclesTheUnit() {
        // Given
        let viewModel = makeViewModel()
        viewModel.reload()

        // When
        viewModel.showNextUnit()

        // Then
        #expect(viewModel.unit == .weeks)
        #expect(viewModel.content.unit == .weeks)
    }

    @Test func showNextUnitOnTheEventsDayThenKeepsDays() {
        // Given
        let viewModel = makeViewModel(events: makeEvents(day: 10))
        viewModel.reload()

        // When
        viewModel.showNextUnit()

        // Then
        #expect(viewModel.unit == .days)
    }

    @Test func editAndShareThenRouteWithTheShownEvent() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)

        // When
        viewModel.edit()
        viewModel.share()

        // Then
        #expect(router.calls == [.editor(.existing(.mockActive)), .sharing(.mockActive)])
    }

    @Test func closeIfDeletedThenLeavesOnlyOnceTheRecordIsGone() {
        // Given
        let router = EventsRouterSpy()
        let events = makeEvents()
        let viewModel = makeViewModel(events: events, router: router)
        viewModel.reload()

        // When
        viewModel.closeIfDeleted()
        let whileStored = router.calls
        events.storedEvents = []
        viewModel.reload()
        viewModel.closeIfDeleted()

        // Then
        #expect(whileStored.isEmpty)
        #expect(router.calls == [.closeDetail(.mockActive)])
    }
}

private extension EventDetailViewModelTests {
    func makeViewModel(
        events: EventRepositorySpy = EventRepositorySpy(
            storedEvents: [.mock(id: .mockActive, day: 22)]
        ),
        router: EventsRouterSpy = EventsRouterSpy()
    ) -> EventDetailViewModel {
        EventDetailViewModel(eventID: .mockActive, events: events, time: .mock(), router: router)
    }

    func makeEvents(
        day: Int = 22,
        focus: UUID? = nil,
        versions: [EventConflictVersion] = []
    ) -> EventRepositorySpy {
        EventRepositorySpy(
            storedEvents: [.mock(id: .mockActive, day: day)],
            storedFocusSelections: focus.map { [.mock(selecting: $0)] } ?? [],
            versions: versions
        )
    }
}
