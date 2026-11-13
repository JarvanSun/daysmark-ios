//
//  LocalSourceReference.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@Model
final class LocalSourceReference {
    var id: UUID = UUID()
    var eventID: UUID = UUID()
    var sourceKindRaw: String = ImportSourceKind.manual.rawValue
    var rawIdentifier: String = ""

    init(
        id: UUID = UUID(),
        eventID: UUID,
        sourceKind: ImportSourceKind,
        rawIdentifier: String
    ) {
        self.id = id
        self.eventID = eventID
        self.sourceKindRaw = sourceKind.rawValue
        self.rawIdentifier = rawIdentifier
    }
}

@Model
final class LocalSourceCleanupRequest {
    var id: UUID = UUID()
    var eventID: UUID = UUID()
    var requestedAt: Date = Date()

    init(id: UUID = UUID(), eventID: UUID, requestedAt: Date) {
        self.id = id
        self.eventID = eventID
        self.requestedAt = requestedAt
    }
}
