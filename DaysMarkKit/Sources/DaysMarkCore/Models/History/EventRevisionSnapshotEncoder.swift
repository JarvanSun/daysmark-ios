//
//  EventRevisionSnapshotEncoder.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

struct EventRevisionSnapshotEncoder {
    func ordinaryReminders(for event: CountdownEvent) -> Data? {
        encode(
            (event.reminders ?? [])
                .sorted { $0.id.uuidString < $1.id.uuidString }
                .map {
                    OrdinaryReminderSnapshot(
                        id: $0.id,
                        kindRaw: $0.kindRaw,
                        minutesBefore: $0.minutesBefore,
                        daysBefore: $0.daysBefore,
                        hour: $0.hour,
                        minute: $0.minute
                    )
                }
        )
    }

    func specialNodes(for event: CountdownEvent) -> Data? {
        encode(
            (event.specialReminderNodes ?? [])
                .sorted { $0.id.uuidString < $1.id.uuidString }
                .map {
                    SpecialReminderNodeSnapshot(id: $0.id, kindRaw: $0.kindRaw, value: $0.value)
                }
        )
    }

    private func encode<T: Encodable>(_ value: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try? encoder.encode(value)
    }
}

struct OrdinaryReminderSnapshot: Codable {
    let id: UUID
    let kindRaw: String?
    let minutesBefore: Int?
    let daysBefore: Int
    let hour: Int
    let minute: Int
}

struct SpecialReminderNodeSnapshot: Codable {
    let id: UUID
    let kindRaw: String
    let value: Int
}
