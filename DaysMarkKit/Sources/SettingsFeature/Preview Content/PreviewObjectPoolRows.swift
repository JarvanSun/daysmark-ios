//
//  PreviewObjectPoolRows.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore
import Foundation

extension PreviewObjectPool {
    var deletedEventTitles: [(title: String, daysAgo: Double)] {
        [("Trip to Lisbon", 1), ("Half marathon in the old town, with the whole club", 12)]
    }

    var categoryRows: [CategoriesContent.Row] {
        [
            CategoriesContent.Row(
                id: UUID(),
                name: "Birthday",
                icon: "gift",
                isBuiltIn: true,
                hasEvents: true
            ),
            CategoriesContent.Row(
                id: UUID(),
                name: "Travel",
                icon: "airplane",
                isBuiltIn: false,
                hasEvents: false
            ),
        ]
    }

    var deletedEventRows: [RecentlyDeletedContent.Row] {
        deletedEventTitles.map { title, daysAgo in
            RecentlyDeletedContent.Row(
                id: UUID(),
                title: title,
                deletedAt: now.addingTimeInterval(-86_400 * daysAgo),
                isHighlighted: daysAgo > 1
            )
        }
    }

    var importDecisions: [ImportDecision] { [.create, .change, .conflict, .unchanged, .deleted] }

    var reminderSuggestion: ImportReminderSuggestion {
        ImportReminderSuggestion(isEnabled: true, daysBefore: 1, time: reminderTime)
    }

    var importResults: [ImportResult] {
        zip(["Mia’s Birthday", "Conference", "Wedding anniversary"], importDecisions).map {
            title,
            decision in
            ImportResult(
                item: ImportedDate(
                    sourceKind: .calendar,
                    sourceIdentifier: title,
                    title: title,
                    date: now.addingTimeInterval(86_400 * 40),
                    repeatsYearly: decision == .create,
                    calendarSystem: .gregorian,
                    timeZone: .gmt,
                    includesTime: false
                ),
                eventID: decision == .create ? nil : UUID(),
                decision: decision
            )
        }
    }
}
#endif
