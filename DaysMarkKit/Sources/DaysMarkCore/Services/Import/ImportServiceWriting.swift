//
//  ImportServiceWriting.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

extension ImportService {
    func results(for scanned: [ImportedDate]) throws(ImportError) -> [ImportResult] {
        guard let localContext = localSources?.mainContext else { throw .localStoreUnavailable }

        do {
            var matcher = ImportMatcher(
                events: try container.mainContext.fetch(FetchDescriptor<CountdownEvent>()),
                references: try localContext.fetch(FetchDescriptor<LocalSourceReference>()),
                localContext: localContext
            )
            var results: [ImportResult] = []

            for item in scanned {
                results.append(matcher.result(for: item))
            }

            if matcher.hasChangedReferences {
                try localContext.save()
            }

            return results
        } catch {
            localContext.rollback()
            throw ImportError(error)
        }
    }

    func write(
        _ results: [ImportResult],
        resolutions: [ImportResult.ID: ImportResolution],
        reminders: [ImportResult.ID: ImportReminderConfiguration]
    ) throws(ImportError) {
        guard let localContext = localSources?.mainContext else { throw .localStoreUnavailable }

        var changes: [ImportedEventChange] = []
        var createdEventIDs = Set<CountdownEvent.ID>()

        for result in results {
            let change = change(
                for: result,
                resolution: resolutions[result.id],
                reminder: reminders[result.id]
            )

            switch change {
            case .create(let id, _, _, _)?:
                createdEventIDs.insert(id)
                localContext.insert(
                    LocalSourceReference(
                        eventID: id,
                        sourceKind: result.item.sourceKind,
                        rawIdentifier: result.item.sourceIdentifier
                    )
                )
            case .update?, .keep?, nil:
                break
            }

            if let change {
                changes.append(change)
            }
        }

        do {
            try categories.seedBuiltInCategories()
            try localContext.save()
            try events.write(changes)
        } catch {
            localContext.rollback()
            removeSavedReferences(to: createdEventIDs, in: localContext)
            throw ImportError(error)
        }
    }
}

// MARK: - Private

private extension ImportService {
    func change(
        for result: ImportResult,
        resolution: ImportResolution?,
        reminder: ImportReminderConfiguration?
    ) -> ImportedEventChange? {
        let item = result.item

        return switch (result.decision, result.eventID, resolution) {
        case (.unchanged, _, _), (.deleted, _, _):
            nil
        case (.create, _, _):
            content(of: item).map {
                .create(id: UUID(), $0, category: category(of: item), reminder: reminder?.draft)
            }
        case (.change, let eventID?, _), (.conflict, let eventID?, .importSource?):
            content(of: item).map { .update(eventID: eventID, $0) }
        case (.conflict, let eventID?, .keepMine?):
            .keep(eventID: eventID, snapshotDigest: ImportSourceDigest(item).rawValue)
        case (.change, nil, _), (.conflict, _, _):
            nil
        }
    }

    func content(of item: ImportedDate) -> ImportedEventContent? {
        let components = item.dateComponents

        guard let year = components.year, let month = components.month, let day = components.day
        else { return nil }

        return ImportedEventContent(
            title: item.title,
            date: EventDateSpecification(
                calendarSystem: item.calendarSystem,
                era: components.era,
                year: year,
                month: month,
                day: day,
                isLeapMonth: components.isLeapMonth ?? false,
                hour: components.hour,
                minute: components.minute
            ),
            timeZone: item.timeZone,
            repeatRule: item.repeatsYearly ? .yearly : .never,
            timeSemantics: item.includesTime ? .floatingLocalTime : .floatingAllDay,
            sourceKind: item.sourceKind,
            snapshotDigest: ImportSourceDigest(item).rawValue
        )
    }

    func category(of item: ImportedDate) -> BuiltInCategory {
        switch item.sourceKind {
        case .contacts: .birthday
        default: .important
        }
    }

    func removeSavedReferences(to eventIDs: Set<CountdownEvent.ID>, in localContext: ModelContext) {
        guard !eventIDs.isEmpty,
            let references = try? localContext.fetch(FetchDescriptor<LocalSourceReference>())
        else { return }

        let orphaned = references.filter { eventIDs.contains($0.eventID) }

        guard !orphaned.isEmpty else { return }

        orphaned.forEach(localContext.delete)
        try? localContext.save()
    }
}
