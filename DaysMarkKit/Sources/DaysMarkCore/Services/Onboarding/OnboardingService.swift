//
//  OnboardingService.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation

@MainActor
public protocol OnboardingCompleting {
    func complete(
        birthday: BirthdayCandidate?,
        selected: Set<OnboardingSeed>
    ) async throws(OnboardingError)
}

@MainActor
public final class OnboardingService {
    private let events: EventRepository
    private let categories: CategoryRepository
    private let notificationPermission: NotificationPermissionRequesting
    private let refresher: SystemSurfaceRefreshing
    private let defaults: UserDefaults
    private let calendar: Calendar
    private let now: () -> Date

    public init(
        events: EventRepository,
        categories: CategoryRepository,
        notificationPermission: NotificationPermissionRequesting,
        refresher: SystemSurfaceRefreshing,
        defaults: UserDefaults,
        calendar: Calendar,
        now: @escaping () -> Date
    ) {
        self.events = events
        self.categories = categories
        self.notificationPermission = notificationPermission
        self.refresher = refresher
        self.defaults = defaults
        self.calendar = calendar
        self.now = now
    }

    public func shouldPresent(eventCount: Int, deletionMarkerCount: Int) -> Bool {
        !defaults.bool(forKey: DefaultsKey.completed.rawValue)
            && eventCount == 0
            && deletionMarkerCount == 0
    }

    func saveSeeds(
        birthday: BirthdayCandidate?,
        selected: Set<OnboardingSeed>
    ) throws(OnboardingError) {
        let plan = OnboardingSeedPlan(calendar: calendar, now: now())
        var seeds: [EventSeed] = []

        for seed in chosenSeeds(from: selected) {
            seeds.append(try plan.eventSeed(for: seed, birthday: birthday))
        }

        do {
            try categories.seedBuiltInCategories()
            try events.seed(seeds)
        } catch {
            throw OnboardingError(error)
        }

        defaults.set(true, forKey: DefaultsKey.completed.rawValue)
    }

    private func chosenSeeds(from selected: Set<OnboardingSeed>) -> [OnboardingSeed] {
        switch selected.isEmpty {
        case true: [.fallbackYearProgress, .fallbackNewYear]
        case false: selected.sorted { $0.rawValue < $1.rawValue }
        }
    }
}

extension OnboardingService {
    private enum DefaultsKey: String {
        case completed = "onboarding.completed"
    }
}

extension OnboardingService: OnboardingCompleting {
    public func complete(
        birthday: BirthdayCandidate?,
        selected: Set<OnboardingSeed>
    ) async throws(OnboardingError) {
        try saveSeeds(birthday: birthday, selected: selected)

        guard selected.contains(.birthday) else { return }

        await notificationPermission.requestIfNeeded()
        refresher.refresh()
    }
}

public struct BirthdayCandidate: Codable, Equatable, Sendable {
    public let date: Date

    public init(date: Date) {
        self.date = date
    }
}
