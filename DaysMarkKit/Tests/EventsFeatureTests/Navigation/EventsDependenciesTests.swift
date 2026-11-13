//
//  EventsDependenciesTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import TestSupport
import Testing

@testable import EventsFeature

struct EventsDependenciesTests {
    @Test func makeHomeViewModelThenWritesThroughTheInjectedRepository() {
        // Given
        let events = EventRepositorySpy()
        let dependencies = EventsDependencies.mock(events: events)
        let viewModel = dependencies.makeHomeViewModel(router: EventsRouterSpy())

        // When
        viewModel.delete(.mockActive)

        // Then
        #expect(events.deletedIDs == [.mockActive])
    }

    @Test func makeEditorViewModelThenStartsFromTheTargetAndTheInjectedDay() {
        // Given
        let dependencies = EventsDependencies.mock()

        // When
        let viewModel = dependencies.makeEditorViewModel(
            target: .new(categoryID: BuiltInCategory.birthday.id),
            router: EventsRouterSpy()
        )

        // Then
        #expect(viewModel.isNew)
        #expect(viewModel.draft.categoryID == BuiltInCategory.birthday.id)
        #expect(viewModel.draft.targetDate == .mockNow)
    }

    @Test func makeDetailViewModelThenTogglesThePinOfItsEvent() {
        // Given
        let events = EventRepositorySpy()
        let dependencies = EventsDependencies.mock(events: events)
        let viewModel = dependencies.makeDetailViewModel(
            eventID: .mockActive,
            router: EventsRouterSpy()
        )

        // When
        viewModel.togglePin()

        // Then
        #expect(events.selections == [.mockActive])
    }

    @Test func makeEditorViewModelThenReadsCategoriesFromTheInjectedRepository() {
        // Given
        let travel = EventCategory(name: "Travel")
        let dependencies = EventsDependencies.mock(
            categories: CategoryRepositorySpy(storedCategories: [travel])
        )
        let viewModel = dependencies.makeEditorViewModel(
            target: .new(categoryID: travel.id),
            router: EventsRouterSpy()
        )

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.categoryChoices.map(\.id) == [travel.id])
    }

    @Test func makeShareViewModelThenReadsItsEventFromTheInjectedRepository() {
        // Given
        let dependencies = EventsDependencies.mock(
            events: EventRepositorySpy(
                storedEvents: [.mock("Shared", id: .mockActive), .mock("Other", id: .mockOther)]
            )
        )
        let viewModel = dependencies.makeShareViewModel(
            eventID: .mockActive,
            router: EventsRouterSpy()
        )

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.content?.title == "Shared")
    }
}
