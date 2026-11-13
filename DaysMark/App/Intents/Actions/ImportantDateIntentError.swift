//
//  ImportantDateIntentError.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

enum ImportantDateIntentError: LocalizedError {
    case emptyTitle
    case invalidDate
    case permanentlyDeleted
    case inRecentlyDeleted
    case storageUnavailable
    case actionFailed

    var errorDescription: String? {
        switch self {
        case .emptyTitle: String(localized: "intent.error.emptyTitle")
        case .invalidDate: String(localized: "intent.error.invalidDate")
        case .permanentlyDeleted: String(localized: "intent.error.permanentlyDeleted")
        case .inRecentlyDeleted: String(localized: "intent.error.inRecentlyDeleted")
        case .storageUnavailable: String(localized: "intent.error.storageUnavailable")
        case .actionFailed: String(localized: "intent.error.actionFailed")
        }
    }

    init(_ error: EventError) {
        switch error {
        case .emptyTitle: self = .emptyTitle
        case .invalidDraft: self = .invalidDate
        case .permanentlyDeleted: self = .permanentlyDeleted
        case .inRecentlyDeleted: self = .inRecentlyDeleted
        case .localStoreUnavailable: self = .storageUnavailable
        case .eventUnavailable, .storeFailure: self = .actionFailed
        }
    }
}
