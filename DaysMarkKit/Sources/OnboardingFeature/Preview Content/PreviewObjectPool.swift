//
//  PreviewObjectPool.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore
import Foundation

struct PreviewObjectPool {
    var now: Date { Date(timeIntervalSince1970: 1_794_484_800) }

    var birthday: Date { Date(timeIntervalSince1970: 946_728_000) }

    var candidates: [OnboardingContent.Candidate] {
        onboardingViewModel(.candidates).content.candidates
    }

    func onboardingDependencies() -> OnboardingDependencies {
        OnboardingDependencies(
            completer: onboardingService(),
            calendar: calendar,
            now: { now },
            onComplete: {}
        )
    }

    func onboardingViewModel(_ state: OnboardingPreviewState) -> OnboardingViewModel {
        let viewModel = OnboardingViewModel(
            birthday: birthday,
            calendar: calendar,
            now: { now },
            completer: PreviewOnboardingCompleter(),
            router: PreviewOnboardingRouter()
        )

        for _ in 0..<state.stepsTaken {
            viewModel.continueToNextStep()
        }

        return viewModel
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    private var defaultsSuite: String { "OnboardingPreview" }

    private func onboardingService() -> OnboardingService {
        let defaults = UserDefaults(suiteName: defaultsSuite) ?? .standard
        defaults.removePersistentDomain(forName: defaultsSuite)

        let now = now
        let container = try! ModelContainerBuilder(role: .app, storage: .inMemory).makeContainer()
        let storeChanges = StoreChanges(notificationCenter: .default)
        let refresher = PreviewSystemSurfaceRefresher()
        let events = SwiftDataEventRepository(
            container: container,
            localSources: nil,
            refresher: refresher,
            storeChanges: storeChanges,
            now: { now },
            timeZone: { .gmt }
        )
        let categories = SwiftDataCategoryRepository(
            container: container,
            events: events,
            storeChanges: storeChanges,
            now: { now }
        )

        return OnboardingService(
            events: events,
            categories: categories,
            notificationPermission: PreviewNotificationPermission(),
            refresher: refresher,
            defaults: defaults,
            calendar: calendar,
            now: { now }
        )
    }
}
#endif
