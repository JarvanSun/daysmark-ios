//
//  FocusSelection.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@Model
public final class FocusSelection {
    public internal(set) var id: UUID = UUID()
    var recordID: UUID = UUID()
    var eventID: UUID?
    var currentRevisionID: UUID?
    var updatedAt: Date = Date()

    init(
        id: UUID,
        recordID: UUID = UUID(),
        eventID: UUID?,
        currentRevisionID: UUID? = nil,
        updatedAt: Date
    ) {
        self.id = id
        self.recordID = recordID
        self.eventID = eventID
        self.currentRevisionID = currentRevisionID
        self.updatedAt = updatedAt
    }
}

@Model
public final class FocusSelectionRevision {
    public internal(set) var id: UUID = UUID()
    var recordID: UUID = UUID()
    var parentRevisionID: UUID?
    var conflictGroupID: UUID = UUID()
    var supersededRevisionIDs: [UUID] = []
    var eventID: UUID?
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        recordID: UUID = UUID(),
        parentRevisionID: UUID?,
        conflictGroupID: UUID,
        supersededRevisionIDs: [UUID] = [],
        eventID: UUID?,
        createdAt: Date
    ) {
        self.id = id
        self.recordID = recordID
        self.parentRevisionID = parentRevisionID
        self.conflictGroupID = conflictGroupID
        self.supersededRevisionIDs = supersededRevisionIDs
        self.eventID = eventID
        self.createdAt = createdAt
    }
}
