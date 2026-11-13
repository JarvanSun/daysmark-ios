//
//  CategoryError.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum CategoryError: Error, Equatable, Sendable {
    case emptyName
    case cannotDeleteBuiltIn
    case categoryUnavailable
    case storeFailure

    init(_ error: Error) {
        self =
            switch error {
            case let error as CategoryError: error
            default: .storeFailure
            }
    }
}
