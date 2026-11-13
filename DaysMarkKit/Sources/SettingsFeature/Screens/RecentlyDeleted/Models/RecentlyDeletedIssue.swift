//
//  RecentlyDeletedIssue.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation

enum RecentlyDeletedIssue: Equatable {
    case actionFailed
    case storageUnavailable
    case batchFailed(count: Int)

    init(_ error: EventError) {
        switch error {
        case .localStoreUnavailable:
            self = .storageUnavailable
        case .emptyTitle, .invalidDraft, .permanentlyDeleted, .inRecentlyDeleted,
            .eventUnavailable, .storeFailure:
            self = .actionFailed
        }
    }
}

extension RecentlyDeletedIssue: IssuePresenting {
    var title: LocalizedStringResource {
        LocalizedStringResource("settings.recentlyDeleted.issue.title", bundle: .module)
    }

    var message: LocalizedStringResource? {
        switch self {
        case .actionFailed: nil
        case .storageUnavailable:
            LocalizedStringResource(
                "settings.recentlyDeleted.issue.storageUnavailable",
                bundle: .module
            )
        case .batchFailed(let count):
            LocalizedStringResource(
                "settings.recentlyDeleted.issue.deleteFailed \(count)",
                bundle: .module
            )
        }
    }
}
