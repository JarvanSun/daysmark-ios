//
//  SpecialNodeAvailability.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

enum SpecialNodeAvailability: Equatable {
    case available
    case targetInPast
    case noFutureOccurrence
    case invalidDate

    var isAvailable: Bool { self == .available }
}

extension SpecialNodeAvailability {
    var message: LocalizedStringResource {
        switch self {
        case .available:
            LocalizedStringResource("editor.specialNodes.availability.available", bundle: .module)
        case .targetInPast:
            LocalizedStringResource("editor.specialNodes.availability.passed", bundle: .module)
        case .noFutureOccurrence:
            LocalizedStringResource(
                "editor.specialNodes.availability.noFutureOccurrence",
                bundle: .module
            )
        case .invalidDate:
            LocalizedStringResource(
                "editor.specialNodes.availability.incalculable",
                bundle: .module
            )
        }
    }
}
