//
//  ImportResult.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct ImportResult: Identifiable, Equatable, Sendable {
    public let item: ImportedDate
    public let eventID: UUID?
    public let decision: ImportDecision

    public var id: String { item.id }

    public init(item: ImportedDate, eventID: UUID?, decision: ImportDecision) {
        self.item = item
        self.eventID = eventID
        self.decision = decision
    }
}

public enum ImportDecision: Equatable, Sendable {
    case create
    case change
    case conflict
    case unchanged
    case deleted
}

public enum ImportResolution: Equatable, Sendable {
    case importSource
    case keepMine
}
