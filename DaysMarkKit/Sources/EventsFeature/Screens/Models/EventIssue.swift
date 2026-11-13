//
//  EventIssue.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation

enum EventIssue: Equatable {
    case actionFailed
    case emptyTitle
    case invalidDate
    case permanentlyDeleted
    case inRecentlyDeleted
    case storageUnavailable
    case batchDeleteFailed(count: Int)

    init(_ error: EventError) {
        switch error {
        case .emptyTitle: self = .emptyTitle
        case .invalidDraft: self = .invalidDate
        case .permanentlyDeleted: self = .permanentlyDeleted
        case .inRecentlyDeleted: self = .inRecentlyDeleted
        case .localStoreUnavailable: self = .storageUnavailable
        case .eventUnavailable, .storeFailure: self = .actionFailed
        }
    }
}

extension EventIssue: IssuePresenting {
    var title: LocalizedStringResource {
        LocalizedStringResource("event.issue.title", bundle: .module)
    }

    var message: LocalizedStringResource? {
        switch self {
        case .actionFailed: nil
        case .emptyTitle: LocalizedStringResource("event.issue.emptyTitle", bundle: .module)
        case .invalidDate: LocalizedStringResource("event.issue.invalidDate", bundle: .module)
        case .permanentlyDeleted:
            LocalizedStringResource("event.issue.permanentlyDeleted", bundle: .module)
        case .inRecentlyDeleted:
            LocalizedStringResource("event.issue.inRecentlyDeleted", bundle: .module)
        case .storageUnavailable:
            LocalizedStringResource("event.issue.storageUnavailable", bundle: .module)
        case .batchDeleteFailed(let count):
            LocalizedStringResource("event.issue.batchDeleteFailed \(count)", bundle: .module)
        }
    }
}
