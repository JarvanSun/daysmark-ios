//
//  WidgetContentReader.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import OSLog
import SwiftData

public actor WidgetContentReader {
    private let open: @Sendable () throws -> ModelContainer

    private let timeZone: @Sendable () -> TimeZone
    private let locale: @Sendable () -> Locale

    private var container: ModelContainer?

    public init(
        storage: StoreStorage,
        timeZone: @escaping @Sendable () -> TimeZone,
        locale: @escaping @Sendable () -> Locale
    ) {
        self.init(timeZone: timeZone, locale: locale) {
            try ModelContainerBuilder(role: .widget, storage: storage).makeContainer()
        }
    }

    init(
        timeZone: @escaping @Sendable () -> TimeZone,
        locale: @escaping @Sendable () -> Locale,
        open: @escaping @Sendable () throws -> ModelContainer
    ) {
        self.timeZone = timeZone
        self.locale = locale
        self.open = open
    }

    public func content(for request: WidgetContentRequest) -> WidgetContent {
        WidgetContentResolver(timeZone: timeZone(), locale: locale())
            .content(for: request, in: storeContents())
    }

    public func timeline(for request: WidgetContentRequest) -> [WidgetContent] {
        let store = storeContents()
        let timeline = WidgetContentResolver(timeZone: timeZone(), locale: locale())
            .timeline(for: request, in: store)
        Logger(category: .data).info(
            "Widget timeline source=\(String(describing: request.source), privacy: .public), events=\(store.events.count), entries=\(timeline.count)"
        )

        return timeline
    }

    public nonisolated func placeholder(titled title: String, for request: WidgetContentRequest)
        -> WidgetContent
    {
        WidgetContentResolver(timeZone: timeZone(), locale: locale())
            .placeholder(titled: title, for: request)
    }

    public func eventOptions(withIDs ids: [CountdownEvent.ID]) -> [WidgetEventOption] {
        let options = Dictionary(
            events(in: context()).map { ($0.id, WidgetEventOption(id: $0.id, title: $0.title)) },
            uniquingKeysWith: { first, _ in first }
        )

        return ids.compactMap { options[$0] }
    }

    public func suggestedEventOptions(at now: Date) -> [WidgetEventOption] {
        Array(sortedEventOptions(at: now).prefix(suggestionLimit))
    }

    public func eventOptions(titled text: String, at now: Date) -> [WidgetEventOption] {
        sortedEventOptions(at: now).filter { $0.title.localizedStandardContains(text) }
    }

    public func categoryOptions() -> [WidgetCategoryOption] {
        categories(in: context()).map {
            WidgetCategoryOption(id: $0.id, name: $0.displayName, icon: $0.icon)
        }
    }

    public func categoryOptions(withIDs ids: [EventCategory.ID]) -> [WidgetCategoryOption] {
        let options = Dictionary(
            categoryOptions().map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        return ids.compactMap { options[$0] }
    }
}

// MARK: - Private

private extension WidgetContentReader {
    var suggestionLimit: Int { 50 }

    func storeContents() -> WidgetStoreContents {
        let context = context()
        let events = events(in: context)
        let selectedID = FocusSelectionResolver().selectedEventID(
            selections: fetch(FetchDescriptor<FocusSelection>(), in: context),
            revisions: fetch(FetchDescriptor<FocusSelectionRevision>(), in: context)
        )

        return WidgetStoreContents(
            events: events,
            categories: categories(in: context),
            focusedEventID: events.contains { $0.id == selectedID } ? selectedID : nil
        )
    }

    func sortedEventOptions(at now: Date) -> [WidgetEventOption] {
        EventSorter().sorted(events(in: context()), now: now, userTimeZone: timeZone())
            .map { WidgetEventOption(id: $0.id, title: $0.event.title) }
    }

    func events(in context: ModelContext?) -> [CountdownEvent] {
        let isActive = #Predicate<CountdownEvent> {
            $0.deletedAt == nil && $0.permanentDeletionRequestedAt == nil
        }

        return fetch(FetchDescriptor(predicate: isActive), in: context)
    }

    func categories(in context: ModelContext?) -> [EventCategory] {
        let isActive = #Predicate<EventCategory> { $0.deletedAt == nil }

        return fetch(
            FetchDescriptor(
                predicate: isActive,
                sortBy: [SortDescriptor(\EventCategory.sortOrder)]
            ),
            in: context
        )
    }

    func fetch<Model: PersistentModel>(
        _ descriptor: FetchDescriptor<Model>,
        in context: ModelContext?
    ) -> [Model] {
        guard let context else { return [] }

        do {
            return try context.fetch(descriptor)
        } catch {
            Logger(category: .data).error(
                "Widget could not read events: \(error.localizedDescription, privacy: .public)"
            )
            return []
        }
    }

    func context() -> ModelContext? {
        if let container { return ModelContext(container) }

        do {
            let opened = try open()
            container = opened

            return ModelContext(opened)
        } catch {
            Logger(category: .data).error(
                "Widget could not open the shared store: \(error.localizedDescription, privacy: .public)"
            )
            return nil
        }
    }
}
