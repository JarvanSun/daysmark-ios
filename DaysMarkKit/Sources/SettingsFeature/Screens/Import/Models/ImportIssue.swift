//
//  ImportIssue.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation

enum ImportIssue {
    case permissionDenied
    case storageUnavailable
    case unknown

    init(_ error: ImportError) {
        switch error {
        case .permissionDenied: self = .permissionDenied
        case .localStoreUnavailable: self = .storageUnavailable
        case .storeFailure: self = .unknown
        }
    }
}

extension ImportIssue: IssuePresenting {
    var title: LocalizedStringResource {
        LocalizedStringResource("settings.import.issue.title", bundle: .module)
    }

    var message: LocalizedStringResource? {
        switch self {
        case .permissionDenied:
            LocalizedStringResource("settings.import.issue.accessDenied", bundle: .module)
        case .storageUnavailable:
            LocalizedStringResource("settings.import.issue.storageUnavailable", bundle: .module)
        case .unknown: nil
        }
    }
}
