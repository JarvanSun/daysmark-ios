//
//  PreviewObjectPool.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore
import Foundation
import SwiftData

struct PreviewObjectPool {
    var now: Date { Date(timeIntervalSince1970: 1_794_484_800) }

    var reminderTime: TimeOfDay { TimeOfDay(hour: 9, minute: 30) }

    var router: SettingsRouting { PreviewSettingsRouter() }

    func settingsDependencies() -> SettingsDependencies {
        let container = modelContainer(.typical)

        return SettingsDependencies(
            events: eventRepository(in: container, at: now),
            categories: categoryRepository(in: container),
            importScanner: PreviewImportService(results: importResults),
            importApplier: PreviewImportService(results: importResults),
            notificationPermission: PreviewNotificationPermission(permission: .notDetermined),
            version: "1.0",
            build: "1"
        )
    }

    func notificationsViewModel(_ state: NotificationsPreviewState) -> NotificationsViewModel {
        NotificationsViewModel(
            permissionRequester: PreviewNotificationPermission(permission: state.permission)
        )
    }

    func categoriesViewModel(_ contents: PreviewContents) -> CategoriesViewModel {
        CategoriesViewModel(
            repository: categoryRepository(in: modelContainer(contents)),
            router: router
        )
    }

    func categoryEditorViewModel(_ target: CategoryEditorTarget) -> CategoryEditorViewModel {
        CategoryEditorViewModel(
            target: target,
            repository: categoryRepository(in: modelContainer(.typical)),
            router: router
        )
    }

    func recentlyDeletedViewModel(_ contents: PreviewContents) -> RecentlyDeletedViewModel {
        RecentlyDeletedViewModel(
            highlightedEventID: nil,
            repository: eventRepository(in: modelContainer(contents), at: now)
        )
    }

    func importViewModel(_ state: ImportPreviewState) -> ImportViewModel {
        let service = PreviewImportService(results: state.hasResults ? importResults : [])
        let viewModel = ImportViewModel(scanner: service, applier: service)

        if state.isScanned {
            viewModel.scan(.calendar, defaultReminderTime: reminderTime)
        }

        return viewModel
    }

    private var deletedEventDay: Date { Date(timeIntervalSince1970: 1_812_801_600) }

    private var storeChanges: StoreChanges {
        StoreChanges(notificationCenter: .default)
    }

    private func modelContainer(_ contents: PreviewContents) -> ModelContainer {
        let container = try! ModelContainerBuilder(role: .app, storage: .inMemory).makeContainer()
        try! seed(contents, into: container)
        return container
    }

    private func categoryRepository(in container: ModelContainer) -> SwiftDataCategoryRepository {
        let now = now

        return SwiftDataCategoryRepository(
            container: container,
            events: eventRepository(in: container, at: now),
            storeChanges: storeChanges,
            now: { now }
        )
    }

    private func eventRepository(in container: ModelContainer, at date: Date)
        -> SwiftDataEventRepository
    {
        SwiftDataEventRepository(
            container: container,
            localSources: nil,
            refresher: PreviewSystemSurfaceRefresher(),
            storeChanges: storeChanges,
            now: { date },
            timeZone: { .gmt }
        )
    }

    private func seed(_ contents: PreviewContents, into container: ModelContainer) throws {
        let categories = categoryRepository(in: container)
        try categories.seedBuiltInCategories()

        guard contents == .typical else { return }

        try categories.save(categoryID: nil, name: "Travel", icon: "airplane")
        try categories.save(
            categoryID: nil,
            name: "Small milestones in everyday life",
            icon: "star"
        )
        let travel = try categories.categories().first { $0.name == "Travel" }

        for (title, daysAgo) in deletedEventTitles {
            let deletedAt = now.addingTimeInterval(-86_400 * daysAgo)
            let events = eventRepository(in: container, at: deletedAt)
            var draft = EventDraft(
                startingOn: deletedEventDay,
                categoryID: travel?.id,
                timeZone: .gmt
            )
            draft.title = title

            try events.delete(eventID: events.save(draft, replacing: nil))
        }
    }
}
#endif
