//
//  ImportantDateRepeatOption.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore

enum ImportantDateRepeatOption: String, AppEnum {
    case never
    case monthly
    case yearly

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "intent.repeat.type"
    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .never: "intent.repeat.never",
        .monthly: "intent.repeat.monthly",
        .yearly: "intent.repeat.yearly",
    ]

    var repeatRule: RepeatRule {
        switch self {
        case .never: .never
        case .monthly: .monthly
        case .yearly: .yearly
        }
    }
}
