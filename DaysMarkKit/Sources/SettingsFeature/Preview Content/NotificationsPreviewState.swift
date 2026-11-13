//
//  NotificationsPreviewState.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore
import Foundation

enum NotificationsPreviewState: String, CaseIterable, CustomStringConvertible {
    case notDetermined
    case authorized
    case denied
    case german

    var description: String { rawValue }

    var permission: NotificationPermission {
        switch self {
        case .notDetermined, .german: .notDetermined
        case .authorized: .authorized
        case .denied: .denied
        }
    }

    var locale: Locale {
        switch self {
        case .german: Locale(identifier: "de_DE")
        case .notDetermined, .authorized, .denied: Locale(identifier: "en_US")
        }
    }
}
#endif
