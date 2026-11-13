//
//  SpotlightIndexer.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/04.
//

import CoreSpotlight
import Foundation
import OSLog
import SwiftData
import UniformTypeIdentifiers

@MainActor
public final class SpotlightIndexer {
    private let container: ModelContainer
    private let timeZone: () -> TimeZone
    private let index = CSSearchableIndex(name: SpotlightIdentifier.index.rawValue)
    private let resolver = EventOccurrenceResolver()

    public init(container: ModelContainer, timeZone: @escaping () -> TimeZone) {
        self.container = container
        self.timeZone = timeZone
    }

    func reindex(at now: Date) async {
        let items = searchableItems(at: now)

        do {
            try await index.deleteSearchableItems(
                withDomainIdentifiers: [SpotlightIdentifier.domain.rawValue]
            )

            if !items.isEmpty {
                try await index.indexSearchableItems(items)
            }
        } catch {
            Logger(category: .data).error(
                "Spotlight indexing failed: \(error.localizedDescription, privacy: .public)"
            )
        }
    }

    private func searchableItems(at now: Date) -> [CSSearchableItem] {
        let context = container.mainContext
        let visible = FetchDescriptor<CountdownEvent>(
            predicate: #Predicate { $0.deletedAt == nil && $0.permanentDeletionRequestedAt == nil }
        )
        let events = (try? context.fetch(visible)) ?? []
        let categories = (try? context.fetch(FetchDescriptor<EventCategory>())) ?? []
        let categoryNames = Dictionary(
            categories.map { ($0.id, $0.displayName) },
            uniquingKeysWith: { first, _ in first }
        )

        return
            events
            .filter { !$0.isSpotlightHidden }
            .compactMap { searchableItem(for: $0, at: now, categoryNames: categoryNames) }
    }

    private func searchableItem(
        for event: CountdownEvent,
        at now: Date,
        categoryNames: [UUID: String]
    ) -> CSSearchableItem? {
        let occurrence = resolver.nextOccurrence(for: event, now: now, userTimeZone: timeZone())

        guard let occurrence else { return nil }

        let attributes = CSSearchableItemAttributeSet(contentType: .data)
        attributes.title = event.title
        attributes.displayName = event.title
        attributes.startDate = occurrence.startDate
        attributes.endDate = occurrence.endDate
        attributes.keywords = [
            categoryNames[event.categoryID]
                ?? String(localized: "spotlight.keyword.fallbackCategory", bundle: .module)
        ]
        attributes.contentDescription = occurrence.startDate.formatted(
            date: .long,
            time: event.timeSemantics == .floatingAllDay ? .omitted : .shortened
        )
        attributes.contentURL = AppRequest.event(event.id).url

        return CSSearchableItem(
            uniqueIdentifier: event.id.uuidString,
            domainIdentifier: SpotlightIdentifier.domain.rawValue,
            attributeSet: attributes
        )
    }
}

enum SpotlightIdentifier: String {
    case index = "ImportantDates"
    case domain = "com.example.daysmark.events"
}
