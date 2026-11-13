//
//  ImportReview.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

enum ImportReview: Equatable {
    case notScanned
    case nothingFound
    case candidates([ImportCandidate])

    var candidates: [ImportCandidate]? {
        switch self {
        case .candidates(let candidates): candidates
        case .notScanned, .nothingFound: nil
        }
    }
}
