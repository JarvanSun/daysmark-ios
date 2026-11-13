//
//  PreviewObjectPool.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore
import DesignSystem
import Foundation
import SettingsFeature
import SwiftData
import SwiftUI

struct PreviewObjectPool {
    var now: Date { Date(timeIntervalSince1970: 1_794_484_800) }

    var eventID: CountdownEvent.ID { UUID(uuidString: "00000000-0000-4000-8000-0000000000A1")! }

    var eventTitle: String { "Mia’s Birthday" }

    var router: EventsRouting { PreviewEventsRouter() }

    var time: CurrentTime {
        time(Locale(identifier: "en_US"))
    }

    func modelContainer(_ contents: PreviewContents = .typical) -> ModelContainer {
        let container = try! ModelContainerBuilder(role: .app, storage: .inMemory).makeContainer()
        try! seed(contents, into: container.mainContext)
        return container
    }

    func eventsDependencies(in container: ModelContainer) -> EventsDependencies {
        EventsDependencies(
            events: eventRepository(in: container),
            categories: categoryRepository(in: container),
            notificationPermission: PreviewNotificationPermission(),
            calendar: .autoupdatingCurrent,
            now: { .now },
            settings: settingsDependencies(in: container)
        )
    }

    func homeViewModel(_ state: EventsPreviewState) -> HomeViewModel {
        let container = modelContainer(state.contents)
        let viewModel = HomeViewModel(
            events: eventRepository(in: container),
            categories: categoryRepository(in: container),
            time: time,
            router: router
        )

        if state == .noMatch {
            viewModel.selectCategory(BuiltInCategory.anniversary.id)
        }

        return viewModel
    }

    func detailViewModel(in container: ModelContainer) -> EventDetailViewModel {
        EventDetailViewModel(
            eventID: eventID,
            events: eventRepository(in: container),
            time: time,
            router: router
        )
    }

    func shareViewModel(_ state: EventsPreviewState) -> EventShareViewModel {
        let container = modelContainer(state.contents)

        return EventShareViewModel(
            eventID: eventID,
            events: eventRepository(in: container),
            categories: categoryRepository(in: container),
            time: time(state.locale),
            router: router
        )
    }

    func editorViewModel(
        _ state: EventsPreviewState,
        in container: ModelContainer
    ) -> EventEditorViewModel {
        let target: EditorTarget =
            switch state {
            case .typical, .german, .longTitles: .existing(eventID)
            case .singleEvent, .empty, .noMatch:
                .new(categoryID: BuiltInCategory.important.id)
            }

        return editorViewModel(for: target, in: container)
    }

    func specialNodesViewModel(_ state: SpecialNodesPreviewState) -> EventEditorViewModel {
        let viewModel = editorViewModel(
            for: .new(categoryID: BuiltInCategory.important.id),
            in: modelContainer(.empty)
        )
        viewModel.draft.title = "Trip to Lisbon"
        viewModel.draft.targetDate = now.addingTimeInterval(86_400 * 400)

        if state.hasNotificationTime {
            viewModel.setSpecialNodeTime(TimeOfDay(hour: 9, minute: 0))
            viewModel.toggleSpecialNode(SpecialNodePreset(kind: .beforeDays, value: 7))
        }

        return viewModel
    }
}

private extension PreviewObjectPool {
    func time(_ locale: Locale) -> CurrentTime {
        CurrentTime(now: now, timeZone: .gmt, locale: locale)
    }

    func eventRepository(in container: ModelContainer) -> SwiftDataEventRepository {
        let now = now

        return SwiftDataEventRepository(
            container: container,
            localSources: nil,
            refresher: PreviewSystemSurfaceRefresher(),
            storeChanges: StoreChanges(notificationCenter: .default),
            now: { now },
            timeZone: { .gmt }
        )
    }

    func categoryRepository(in container: ModelContainer) -> SwiftDataCategoryRepository {
        let now = now

        return SwiftDataCategoryRepository(
            container: container,
            events: eventRepository(in: container),
            storeChanges: StoreChanges(notificationCenter: .default),
            now: { now }
        )
    }

    func settingsDependencies(in container: ModelContainer) -> SettingsDependencies {
        let importService = importService(in: container)

        return SettingsDependencies(
            events: eventRepository(in: container),
            categories: categoryRepository(in: container),
            importScanner: importService,
            importApplier: importService,
            notificationPermission: PreviewNotificationPermission(),
            version: "1.0",
            build: "1"
        )
    }

    func importService(in container: ModelContainer) -> ImportService {
        let now = now

        return ImportService(
            container: container,
            localSources: nil,
            events: eventRepository(in: container),
            categories: categoryRepository(in: container),
            notificationPermission: PreviewNotificationPermission(),
            refresher: PreviewSystemSurfaceRefresher(),
            now: { now },
            calendar: { Calendar(identifier: .gregorian) }
        )
    }

    func editorViewModel(
        for target: EditorTarget,
        in container: ModelContainer
    ) -> EventEditorViewModel {
        let now = now

        return EventEditorViewModel(
            target: target,
            events: eventRepository(in: container),
            categories: categoryRepository(in: container),
            permissionRequester: PreviewNotificationPermission(),
            calendar: Calendar(identifier: .gregorian),
            now: { now },
            router: router
        )
    }

    func seed(_ contents: PreviewContents, into context: ModelContext) throws {
        try categoryRepository(in: context.container).seedBuiltInCategories()

        for event in events(for: contents) {
            context.insert(event)
        }

        try context.save()
    }
}
#endif
