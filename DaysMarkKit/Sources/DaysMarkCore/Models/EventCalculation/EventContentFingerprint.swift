//
//  EventContentFingerprint.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct EventContentFingerprint: Equatable {
    let rawValue: String

    init(_ event: CountdownEvent) {
        let title = event.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let day =
            "\(event.targetEra ?? 0)-\(event.targetYear)-\(event.targetMonth)-\(event.targetDay)-\(event.targetIsLeapMonth)"
        let time = "\(event.targetHour ?? -1):\(event.targetMinute ?? -1)"

        rawValue =
            [
                title,
                day,
                time,
                event.timeSemanticsRaw,
                event.calendarSystemRaw,
                event.timeZoneIdentifier,
                event.repeatRule.rawValue,
                event.categoryID.uuidString,
            ]
            .joined(separator: "|")
            .sha256Digest
    }
}
