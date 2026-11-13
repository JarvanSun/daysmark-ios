//
//  ImportAccess.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Contacts
import EventKit

enum ImportAccess: Equatable {
    case undetermined
    case granted
    case denied

    init(_ status: CNAuthorizationStatus) {
        self =
            switch status {
            case .notDetermined: .undetermined
            case .authorized, .limited: .granted
            default: .denied
            }
    }

    init(_ status: EKAuthorizationStatus) {
        self =
            switch status {
            case .notDetermined: .undetermined
            case .fullAccess: .granted
            default: .denied
            }
    }
}
