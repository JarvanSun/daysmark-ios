//
//  AppRootViewModelTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DaysMarkCore
import Foundation
import SwiftData
import Testing

@testable import DaysMark

struct AppRootViewModelTests {
    @Test func refreshOnboardingOnAFreshInstallThenShowsOnboarding() throws {
        // Given
        let viewModel = try makeViewModel()

        // When
        viewModel.refreshOnboarding()

        // Then
        #expect(viewModel.showsOnboarding)
    }

    @Test func refreshOnboardingWithAnEventThenSkipsIt() throws {
        // Given
        let container = try ModelContainer.mockInMemory()
        let events = SwiftDataEventRepository.mock(in: container)
        let viewModel = AppRootViewModel(
            onboarding: try OnboardingService.mock(defaults: .mockEmpty()),
            events: events
        )
        try saveEvent(in: container, to: events)

        // When
        viewModel.refreshOnboarding()

        // Then
        #expect(!viewModel.showsOnboarding)
    }

    @Test func finishOnboardingThenShowsTheApp() throws {
        // Given
        let viewModel = try makeViewModel()
        viewModel.refreshOnboarding()

        // When
        viewModel.finishOnboarding()

        // Then
        #expect(!viewModel.showsOnboarding)
    }

    @Test func openAURLThenHoldsItsRequest() throws {
        // Given
        let viewModel = try makeViewModel()
        let url = try #require(URL(string: "daysmark://collection/birthdays"))

        // When
        viewModel.open(url)

        // Then
        #expect(viewModel.pendingRequest == .collection(.birthdays))
    }

    @Test(arguments: [
        "other://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA",
        "daysmark://event/not-a-uuid",
        "daysmark://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA/extra",
        "daysmark://event/AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA?source=test",
    ])
    func openAnUnexpectedURLThenKeepsThePendingRequest(link: String) throws {
        // Given
        let viewModel = try makeViewModel()
        viewModel.pendingRequest = .widgets

        // When
        viewModel.open(try #require(URL(string: link)))

        // Then
        #expect(viewModel.pendingRequest == .widgets)
    }

    @Test func openARequestThenHoldsItAndIgnoresAMissingOne() throws {
        // Given
        let viewModel = try makeViewModel()

        // When
        viewModel.open(AppRequest.search)
        viewModel.open(AppRequest?.none)

        // Then
        #expect(viewModel.pendingRequest == .search)
    }

    private func makeViewModel() throws -> AppRootViewModel {
        AppRootViewModel(
            onboarding: try OnboardingService.mock(defaults: .mockEmpty()),
            events: SwiftDataEventRepository.mock(in: try ModelContainer.mockInMemory())
        )
    }

    private func saveEvent(in container: ModelContainer, to events: EventRepository) throws {
        let lookup = EventLookup(
            container: container,
            now: { .mockNow },
            timeZone: { .gmt },
            locale: { Locale(identifier: "en_US") }
        )
        let candidate = try lookup.candidate(
            creating: EventCreationInput(title: "Trip", startDate: .mockNow)
        )

        _ = try events.save(candidate.draft, replacing: nil)
    }
}
