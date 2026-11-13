//
//  ImportedEventChange.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum ImportedEventChange: Sendable {
    case create(
        id: CountdownEvent.ID,
        ImportedEventContent,
        category: BuiltInCategory,
        reminder: ReminderDraft?
    )
    case update(eventID: CountdownEvent.ID, ImportedEventContent)
    case keep(eventID: CountdownEvent.ID, snapshotDigest: String)
}

public struct ImportedEventContent: Sendable {
    let title: String
    let date: EventDateSpecification
    let timeZone: TimeZone
    let repeatRule: RepeatRule
    let timeSemantics: EventTimeSemantics
    let sourceKind: ImportSourceKind
    let snapshotDigest: String
}
