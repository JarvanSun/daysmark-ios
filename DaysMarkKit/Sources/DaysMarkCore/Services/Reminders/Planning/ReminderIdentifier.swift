//
//  ReminderIdentifier.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct ReminderIdentifier: Equatable, Sendable {
    let eventID: UUID
    let subject: Subject
    let occurrence: Date

    var rawValue: String {
        switch subject {
        case .rule(let id): "\(eventID.uuidString).\(id.uuidString).\(occurrenceKey)"
        case .specialNode(let id): "\(eventID.uuidString).special.\(id.uuidString).\(occurrenceKey)"
        }
    }

    private var occurrenceKey: Int64 { Int64(occurrence.timeIntervalSince1970.rounded(.down)) }
}

extension ReminderIdentifier {
    enum Subject: Equatable, Sendable {
        case rule(UUID)
        case specialNode(UUID)
    }
}
