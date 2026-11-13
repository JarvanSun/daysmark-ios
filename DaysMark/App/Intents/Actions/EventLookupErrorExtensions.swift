//
//  EventLookupErrorExtensions.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore

extension EventLookupError {
    var intentError: Error {
        switch self {
        case .eventNotFound: AppIntentError.Unrecoverable.entityNotFound
        case .reminderNotAllowed: AppIntentError.Unrecoverable.notAllowed
        case .invalidDraft: ImportantDateIntentError.invalidDate
        }
    }
}
