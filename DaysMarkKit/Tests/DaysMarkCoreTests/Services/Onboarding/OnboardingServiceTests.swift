//
//  OnboardingServiceTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/04.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct OnboardingServiceTests {
    @Test
    func completeThenSeedsTheSelectedEventsOnceAndRefreshesOnce() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let permission = NotificationPermissionRequesterSpy()
        let refresher = SystemSurfaceRefresherSpy()
        let service = OnboardingService.mock(
            in: container,
            notificationPermission: permission,
            refresher: refresher
        )
        let selected: Set<OnboardingSeed> = [.newYear, .nextMonth, .monthEnd]

        // When
        try await service.complete(birthday: nil, selected: selected)
        try await service.complete(birthday: nil, selected: selected)

        // Then
        let events = try container.mainContext.fetch(FetchDescriptor<CountdownEvent>())
        let monthEnd = events.first { $0.seedIdentifier == OnboardingSeed.monthEnd.rawValue }
        #expect(events.count == 3)
        #expect(
            events.allSatisfy {
                $0.sourceKind == .seeded
                    && $0.currentRevisionID == $0.id
                    && $0.categoryID == BuiltInCategory.important.id
            }
        )
        #expect(monthEnd?.repeatRule == .monthlyLastDay)
        #expect(permission.requestCount == 0)
        #expect(refresher.refreshCount == 2)
    }

    @Test
    func completeWithoutASelectionThenSeedsTheTwoFallbackEvents() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let service = OnboardingService.mock(in: container)

        // When
        try await service.complete(birthday: nil, selected: [])

        // Then
        let events = try container.mainContext.fetch(FetchDescriptor<CountdownEvent>())
        let yearProgress = try #require(
            events.first { $0.seedIdentifier == OnboardingSeed.fallbackYearProgress.rawValue }
        )
        let occurrence = try #require(
            EventOccurrenceResolver().nextOccurrence(
                for: yearProgress,
                now: .mock(2027, 6, 1),
                userTimeZone: .mockUTC
            )
        )
        #expect(
            Set(events.compactMap(\.seedIdentifier)) == [
                OnboardingSeed.fallbackYearProgress.rawValue,
                OnboardingSeed.fallbackNewYear.rawValue,
            ]
        )
        #expect(yearProgress.repeatRule == .currentYearStart)
        #expect(occurrence.start.year == 2027)
        #expect(occurrence.start.month == 1)
        #expect(occurrence.start.day == 1)
    }

    @Test
    func completeWithABirthdayThenSeedsItWithRemindersAsksForPermissionAndRefreshes() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let permission = NotificationPermissionRequesterSpy()
        let refresher = SystemSurfaceRefresherSpy()
        let service = OnboardingService.mock(
            in: container,
            notificationPermission: permission,
            refresher: refresher
        )

        // When
        try await service.complete(
            birthday: BirthdayCandidate(date: .mock(1991, 2, 14)),
            selected: [.birthday, .birthDate]
        )

        // Then
        let events = try container.mainContext.fetch(FetchDescriptor<CountdownEvent>())
        let annual = try #require(
            events.first { $0.seedIdentifier == OnboardingSeed.birthday.rawValue }
        )
        let birthDate = try #require(
            events.first { $0.seedIdentifier == OnboardingSeed.birthDate.rawValue }
        )
        #expect(annual.repeatRule == .yearly)
        #expect(Set((annual.reminders ?? []).map(\.daysBefore)) == [7, 1, 0])
        #expect((annual.reminders ?? []).allSatisfy { $0.hour == 9 && $0.minute == 0 })
        #expect(birthDate.repeatRule == .never)
        #expect(birthDate.reminders?.isEmpty ?? true)
        #expect(events.allSatisfy { $0.categoryID == BuiltInCategory.birthday.id })
        #expect(permission.requestCount == 1)
        #expect(refresher.refreshCount == 2)
    }

    @Test
    func completeWhenTheBirthdayIsMissingThenThrowsInvalidBirthdayAndSeedsNothing() async {
        // Given
        let events = EventRepositorySpy()
        let defaults = UserDefaults.mockEmpty()
        let service = OnboardingService.mock(events: events, defaults: defaults)

        // When / Then
        await #expect(throws: OnboardingError.invalidBirthday) {
            try await service.complete(birthday: nil, selected: [.monthEnd, .birthday])
        }
        #expect(events.seeds.isEmpty)
        #expect(service.shouldPresent(eventCount: 0, deletionMarkerCount: 0))
    }

    @Test(arguments: [true, false])
    func completeWhenAStoreFailsThenThrowsStoreFailureAndStaysIncomplete(
        failsWhileSeedingCategories: Bool
    ) async {
        // Given
        let refresher = SystemSurfaceRefresherSpy()
        let service = OnboardingService.mock(
            events: EventRepositorySpy(error: failsWhileSeedingCategories ? nil : .storeFailure),
            categories: CategoryRepositorySpy(
                error: failsWhileSeedingCategories ? .storeFailure : nil
            ),
            refresher: refresher
        )

        // When / Then
        await #expect(throws: OnboardingError.storeFailure) {
            try await service.complete(birthday: nil, selected: [.newYear])
        }
        #expect(service.shouldPresent(eventCount: 0, deletionMarkerCount: 0))
        #expect(refresher.refreshCount == 0)
    }

    @Test
    func completeThenStoresTheCompletionUnderItsKey() async throws {
        // Given
        let defaults = UserDefaults.mockEmpty()
        let service = OnboardingService.mock(defaults: defaults)

        // When
        try await service.complete(birthday: nil, selected: [.newYear])

        // Then
        #expect(defaults.bool(forKey: "onboarding.completed"))
        #expect(!service.shouldPresent(eventCount: 0, deletionMarkerCount: 0))
    }

    @Test(arguments: [(0, 0, true), (1, 0, false), (0, 1, false)])
    func shouldPresentWhenIncompleteThenHoldsOnlyForAnEmptyStore(
        eventCount: Int,
        deletionMarkerCount: Int,
        expected: Bool
    ) {
        // Given
        let service = OnboardingService.mock()

        // When
        let shouldPresent = service.shouldPresent(
            eventCount: eventCount,
            deletionMarkerCount: deletionMarkerCount
        )

        // Then
        #expect(shouldPresent == expected)
    }
}
