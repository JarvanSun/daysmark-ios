//
//  PermanentDeletionMarker.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@Model
public final class PermanentDeletionMarker {
    public internal(set) var id: UUID = UUID()
    var eventID: UUID = UUID()
    var seedIdentifier: String?
    var deletedAt: Date = Date()

    init(
        id: UUID = UUID(),
        eventID: UUID,
        seedIdentifier: String? = nil,
        deletedAt: Date
    ) {
        self.id = id
        self.eventID = eventID
        self.seedIdentifier = seedIdentifier
        self.deletedAt = deletedAt
    }
}
