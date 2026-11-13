//
//  OnboardingError.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum OnboardingError: Error, Equatable, Sendable {
    case invalidBirthday
    case dateUnavailable
    case storeFailure

    init(_ error: Error) {
        self =
            switch error {
            case let error as OnboardingError: error
            default: .storeFailure
            }
    }
}
