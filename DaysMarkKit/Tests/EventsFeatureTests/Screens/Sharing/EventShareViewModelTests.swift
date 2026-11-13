//
//  EventShareViewModelTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import TestSupport
import Testing

@testable import EventsFeature

struct EventShareViewModelTests {
    @Test func contentThenFollowsTheCategoryChoice() {
        // Given
        let category = EventCategory(name: "Travel")
        let event = CountdownEvent.mock(id: .mockActive, category: category)
        let viewModel = makeViewModel(
            events: EventRepositorySpy(storedEvents: [event]),
            categories: CategoryRepositorySpy(storedCategories: [category])
        )
        viewModel.reload()

        // When
        let closed = viewModel.content
        viewModel.includesCategory = true
        let open = viewModel.content

        // Then
        #expect(closed?.category == nil)
        #expect(open?.category == "Travel")
    }

    @Test func contentThenSharesOnlyTheChosenEvent() {
        // Given
        let viewModel = makeViewModel(
            events: EventRepositorySpy(
                storedEvents: [.mock("Other", id: .mockOther), .mock("Shared", id: .mockActive)]
            )
        )

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.content?.title == "Shared")
    }

    @Test(arguments: [false, true])
    func contentWithoutTheEventThenIsMissing(isDeleted: Bool) {
        // Given
        let events = isDeleted ? [CountdownEvent.mockDeleted(id: .mockActive)] : []
        let viewModel = makeViewModel(events: EventRepositorySpy(storedEvents: events))
        viewModel.reload()

        // Then
        #expect(viewModel.content == nil)
    }

    @Test func reloadWhenTheStoreFailsThenShowsNothing() {
        // Given
        let events = EventRepositorySpy(storedEvents: [.mock(id: .mockActive)])
        let viewModel = makeViewModel(events: events)
        viewModel.reload()
        events.readError = .storeFailure

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.content == nil)
    }

    @Test func finishThenDismissesTheSheet() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)

        // When
        viewModel.finish()

        // Then
        #expect(router.calls == [.dismissSheet])
    }

    private func makeViewModel(
        events: EventRepositorySpy = EventRepositorySpy(),
        categories: CategoryRepositorySpy = CategoryRepositorySpy(),
        router: EventsRouterSpy = EventsRouterSpy()
    ) -> EventShareViewModel {
        EventShareViewModel(
            eventID: .mockActive,
            events: events,
            categories: categories,
            time: .mock(),
            router: router
        )
    }
}
