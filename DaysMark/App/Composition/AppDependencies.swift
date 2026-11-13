//
//  AppDependencies.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/09/04.
//

import AppIntents
import DaysMarkCore
import EventsFeature
import Foundation
import OnboardingFeature
import SettingsFeature
import SwiftData

struct AppDependencies {
    let intentRequests: AppRequestInbox

    private let configuration: AppConfiguration
    private let widgetReloader: SystemWidgetReloader
    private let reminderService: ReminderService
    private let refresher: SystemSurfaceRefresher
    private let eventRepository: SwiftDataEventRepository
    private let eventLookup: EventLookup
    private let categoryRepository: SwiftDataCategoryRepository
    private let storeRepair: StoreRepair
    private let importService: ImportService
    private let onboardingService: OnboardingService

    init(configuration: AppConfiguration) {
        #if DEBUG
        CloudKitSchemaInitializer(arguments: ProcessInfo.processInfo.arguments).runIfRequested()
        #endif

        let builder = ModelContainerBuilder(role: .app, storage: .appGroup)

        let modelContainer: ModelContainer

        do {
            modelContainer = try builder.makeContainer()
        } catch {
            fatalError("Could not create model container: \(error)")
        }

        let localSourceContainer = builder.makeLocalSourceContainer()
        let storeChanges = StoreChanges(notificationCenter: .default)
        let widgetReloader = SystemWidgetReloader()
        let reminderService = ReminderService(
            container: modelContainer,
            scheduler: SystemNotificationScheduler(),
            authorizer: SystemNotificationAuthorizer(),
            now: { .now },
            timeZone: { .current }
        )
        let refresher = SystemSurfaceRefresher(
            reminders: reminderService,
            widgets: widgetReloader,
            spotlight: SpotlightIndexer(container: modelContainer, timeZone: { .current }),
            liveActivities: LiveActivityService(
                container: modelContainer,
                defaults: builder.sharedDefaults,
                timeZone: { .current }
            ),
            now: { .now }
        )
        let eventRepository = SwiftDataEventRepository(
            container: modelContainer,
            localSources: localSourceContainer,
            refresher: refresher,
            storeChanges: storeChanges,
            now: { .now },
            timeZone: { .current }
        )
        let categoryRepository = SwiftDataCategoryRepository(
            container: modelContainer,
            events: eventRepository,
            storeChanges: storeChanges,
            now: { .now }
        )

        self.configuration = configuration
        self.widgetReloader = widgetReloader
        self.reminderService = reminderService
        self.refresher = refresher
        self.eventRepository = eventRepository
        self.categoryRepository = categoryRepository
        intentRequests = AppRequestInbox()
        eventLookup = EventLookup(
            container: modelContainer,
            now: { .now },
            timeZone: { .current },
            locale: { .current }
        )
        storeRepair = StoreRepair(
            container: modelContainer,
            localSources: localSourceContainer,
            now: { .now }
        )
        importService = ImportService(
            container: modelContainer,
            localSources: localSourceContainer,
            events: eventRepository,
            categories: categoryRepository,
            notificationPermission: reminderService,
            refresher: refresher,
            now: { .now },
            calendar: { .current }
        )
        onboardingService = OnboardingService(
            events: eventRepository,
            categories: categoryRepository,
            notificationPermission: reminderService,
            refresher: refresher,
            defaults: .standard,
            calendar: .autoupdatingCurrent,
            now: { .now }
        )
    }

    func events() -> EventsDependencies {
        EventsDependencies(
            events: eventRepository,
            categories: categoryRepository,
            notificationPermission: reminderService,
            calendar: .autoupdatingCurrent,
            now: { .now },
            settings: settings()
        )
    }

    func settings() -> SettingsDependencies {
        SettingsDependencies(
            events: eventRepository,
            categories: categoryRepository,
            importScanner: importService,
            importApplier: importService,
            notificationPermission: reminderService,
            version: configuration.version,
            build: configuration.build
        )
    }

    func onboarding(onComplete: @escaping () -> Void) -> OnboardingDependencies {
        OnboardingDependencies(
            completer: onboardingService,
            calendar: .autoupdatingCurrent,
            now: { .now },
            onComplete: onComplete
        )
    }

    func rootViewModel() -> AppRootViewModel {
        AppRootViewModel(onboarding: onboardingService, events: eventRepository)
    }

    func registerIntentDependencies() {
        let eventLookup = eventLookup
        let events: EventRepository = eventRepository
        let intentRequests = intentRequests

        AppDependencyManager.shared.add(dependency: eventLookup)
        AppDependencyManager.shared.add(dependency: events)
        AppDependencyManager.shared.add(dependency: intentRequests)
    }

    func lifecycle() -> AppLifecycle {
        AppLifecycle(
            categories: categoryRepository,
            storeRepair: storeRepair,
            reminderService: reminderService,
            refresher: refresher,
            backgroundRefresh: BackgroundRefresh(
                reminders: reminderService,
                widgets: widgetReloader,
                scheduler: SystemBackgroundTaskScheduler(),
                now: { .now }
            )
        )
    }
}
