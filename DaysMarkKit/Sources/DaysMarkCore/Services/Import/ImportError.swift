//
//  ImportError.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum ImportError: Error, Equatable, Sendable {
    case permissionDenied
    case localStoreUnavailable
    case storeFailure

    init(_ error: Error) {
        self =
            switch error {
            case let error as ImportError: error
            default: .storeFailure
            }
    }
}
