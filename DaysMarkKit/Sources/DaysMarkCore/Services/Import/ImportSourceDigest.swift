//
//  ImportSourceDigest.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct ImportSourceDigest: Equatable {
    let rawValue: String

    init(_ item: ImportedDate) {
        let title = item.title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let components = item.dateComponents
        let day =
            "\(components.era ?? 0)-\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)-\(components.isLeapMonth ?? false)"
        let moment =
            switch (components.hour, components.minute) {
            case (let hour?, let minute?): "\(day)T\(hour):\(minute)"
            default: day
            }
        let timeZone =
            switch item.sourceKind {
            case .contacts: "all-day"
            default: item.timeZone.identifier
            }

        rawValue =
            [
                item.sourceKind.rawValue,
                title,
                moment,
                "\(item.repeatsYearly)",
                item.calendarSystem.rawValue,
                timeZone,
            ]
            .joined(separator: "|")
            .sha256Digest
    }
}
