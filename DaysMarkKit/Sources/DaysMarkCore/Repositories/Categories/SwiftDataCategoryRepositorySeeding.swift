//
//  SwiftDataCategoryRepositorySeeding.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

extension SwiftDataCategoryRepository {
    public func seedBuiltInCategories() throws(CategoryError) {
        try write {
            let existing = try context.fetch(FetchDescriptor<EventCategory>())
            let events = try context.fetch(FetchDescriptor<CountdownEvent>())

            for kind in BuiltInCategory.allCases {
                converge(kind, among: existing, relinking: events)
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    private func converge(
        _ kind: BuiltInCategory,
        among existing: [EventCategory],
        relinking events: [CountdownEvent]
    ) {
        let matches = existing.filter { $0.id == kind.id || $0.builtInKind == kind }
        let originalIDs = Set(matches.map(\.id))
        let originalRecords = Set(matches.map(\.persistentModelID))
        let canonical = canonicalCategory(of: kind, among: matches)

        for event in events {
            let relatedRecord = event.category?.persistentModelID

            if event.currentRevisionID == nil,
                let related = event.category,
                related.builtInKind == nil,
                related.deletedAt == nil,
                !originalRecords.contains(related.persistentModelID)
            {
                continue
            }

            let ownsKind = originalIDs.contains(event.categoryID) || event.categoryID == kind.id

            guard ownsKind || relatedRecord.map(originalRecords.contains) == true else { continue }

            if ownsKind && event.categoryID != kind.id {
                event.categoryID = kind.id
            }

            if relatedRecord != canonical.persistentModelID {
                event.category = canonical
            }
        }

        for duplicate in matches where duplicate !== canonical {
            context.delete(duplicate)
        }
    }

    private func canonicalCategory(
        of kind: BuiltInCategory,
        among matches: [EventCategory]
    ) -> EventCategory {
        guard let canonical = matches.min(by: { $0.recordID.uuidString < $1.recordID.uuidString })
        else {
            let seeded = EventCategory(builtIn: kind)
            context.insert(seeded)

            return seeded
        }

        let isLegacy = canonical.id != kind.id || canonical.builtInKindRaw != kind.rawValue

        if canonical.id != kind.id {
            canonical.id = kind.id
        }

        if canonical.builtInKindRaw != kind.rawValue {
            canonical.builtInKindRaw = kind.rawValue
        }

        if canonical.icon != kind.icon {
            canonical.icon = kind.icon
        }

        if canonical.deletedAt != nil {
            canonical.deletedAt = nil
        }

        if isLegacy && canonical.sortOrder != kind.sortOrder {
            canonical.sortOrder = kind.sortOrder
        }

        return canonical
    }
}
