//
//  EventLookup.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@MainActor
public struct EventLookup {
    let now: () -> Date
    let timeZone: () -> TimeZone
    let locale: () -> Locale

    private let container: ModelContainer

    public init(
        container: ModelContainer,
        now: @escaping () -> Date,
        timeZone: @escaping () -> TimeZone,
        locale: @escaping () -> Locale
    ) {
        self.container = container
        self.now = now
        self.timeZone = timeZone
        self.locale = locale
    }

    private var context: ModelContext { container.mainContext }

    public func events(withIDs ids: [CountdownEvent.ID]) -> [EventMatch] {
        let wanted = Set(ids)

        return activeEvents().filter { wanted.contains($0.id) }.compactMap(match)
    }

    public func events(titled text: String) -> [EventMatch] {
        activeEvents().filter { $0.title.localizedStandardContains(text) }.compactMap(match)
    }

    public func nearestEvents(limit: Int, in categoryID: EventCategory.ID?) -> [EventMatch] {
        let filtered = activeEvents().filter { categoryID == nil || $0.categoryID == categoryID }

        return EventSorter().sorted(filtered, now: now(), userTimeZone: timeZone())
            .prefix(min(max(limit, 1), maximumResultCount))
            .compactMap { match($0.event) }
    }

    private var maximumResultCount: Int { 3 }

    public func distancePhrase(for eventID: CountdownEvent.ID) -> String? {
        let now = now()
        let timeZone = timeZone()

        guard
            let event = activeEvents().first(where: { $0.id == eventID }),
            let counted = EventSorter().counted([event], now: now, userTimeZone: timeZone).first
        else { return nil }

        return counted.relativeTimePhrase(at: now, userTimeZone: timeZone, locale: locale()).text
    }

    public func categories() -> [CategoryMatch] {
        let fetched = (try? context.fetch(FetchDescriptor<EventCategory>())) ?? []

        return fetched.filter { $0.deletedAt == nil }.map {
            CategoryMatch(id: $0.id, name: $0.displayName)
        }
    }

    public func categories(withIDs ids: [EventCategory.ID]) -> [CategoryMatch] {
        let wanted = Set(ids)

        return categories().filter { wanted.contains($0.id) }
    }

    public func categories(named text: String) -> [CategoryMatch] {
        categories().filter { $0.name.localizedStandardContains(text) }
    }

    func activeEvents() -> [CountdownEvent] {
        let all = (try? context.fetch(FetchDescriptor<CountdownEvent>())) ?? []

        return all.filter { $0.deletedAt == nil && $0.permanentDeletionRequestedAt == nil }
    }

    private func match(_ event: CountdownEvent) -> EventMatch? {
        let now = now()
        let timeZone = timeZone()
        let occurrence = EventOccurrenceResolver().nextOccurrence(
            for: event,
            now: now,
            userTimeZone: timeZone
        )

        guard let occurrence else { return nil }

        return EventMatch(
            id: event.id,
            title: event.title,
            date: occurrence.referenceDate(
                now: now,
                semantics: event.timeSemantics,
                userTimeZone: timeZone
            ),
            categoryName: categoryName(for: event.categoryID)
        )
    }

    func categoryName(for categoryID: EventCategory.ID?) -> String {
        categories().first { $0.id == categoryID }?.name
            ?? String(localized: "lookup.category.fallback", bundle: .module)
    }
}

public struct EventMatch: Identifiable, Equatable, Sendable {
    public let id: CountdownEvent.ID
    public let title: String
    public let date: Date
    public let categoryName: String
}

public struct CategoryMatch: Identifiable, Equatable, Sendable {
    public let id: EventCategory.ID
    public let name: String
}

public enum EventLookupError: Error, Equatable, Sendable {
    case eventNotFound
    case reminderNotAllowed
    case invalidDraft
}
