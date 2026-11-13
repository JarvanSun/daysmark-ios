//
//  AppRootViewModel.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DaysMarkCore
import Foundation
import OSLog
import Observation

@Observable
final class AppRootViewModel {
    var pendingRequest: AppRequest?

    private(set) var showsOnboarding = false

    private let onboarding: OnboardingService
    private let events: EventRepository

    init(onboarding: OnboardingService, events: EventRepository) {
        self.onboarding = onboarding
        self.events = events
    }

    func observeStore() async {
        refreshOnboarding()

        for await _ in events.changes() {
            refreshOnboarding()
        }
    }

    func refreshOnboarding() {
        do {
            showsOnboarding = onboarding.shouldPresent(
                eventCount: try events.events().count,
                deletionMarkerCount: try events.permanentDeletionMarkers().count
            )
        } catch {
            Logger(category: .data).error(
                "Reading the store failed: \(String(describing: error), privacy: .public)"
            )
        }
    }

    func finishOnboarding() {
        showsOnboarding = false
    }

    func open(_ url: URL) {
        open(AppRequest(url: url))
    }

    func open(_ request: AppRequest?) {
        guard let request else { return }

        pendingRequest = request
    }
}
