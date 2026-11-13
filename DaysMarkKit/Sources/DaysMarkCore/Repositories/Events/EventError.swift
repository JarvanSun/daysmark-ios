//
//  EventError.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum EventError: Error, Equatable, Sendable {
    case emptyTitle
    case invalidDraft
    case permanentlyDeleted
    case inRecentlyDeleted
    case eventUnavailable
    case localStoreUnavailable
    case storeFailure

    init(_ error: Error) {
        self =
            switch error {
            case let error as EventError: error
            default: .storeFailure
            }
    }
}
