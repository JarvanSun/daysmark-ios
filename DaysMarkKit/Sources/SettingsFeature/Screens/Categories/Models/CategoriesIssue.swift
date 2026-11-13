//
//  CategoriesIssue.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation

enum CategoriesIssue {
    case emptyName
    case builtInCategory
    case categoryUnavailable
    case unknown

    init(_ error: CategoryError) {
        switch error {
        case .emptyName: self = .emptyName
        case .cannotDeleteBuiltIn: self = .builtInCategory
        case .categoryUnavailable: self = .categoryUnavailable
        case .storeFailure: self = .unknown
        }
    }
}

extension CategoriesIssue: IssuePresenting {
    var title: LocalizedStringResource {
        LocalizedStringResource("settings.categories.issue.title", bundle: .module)
    }

    var message: LocalizedStringResource? {
        switch self {
        case .emptyName:
            LocalizedStringResource("settings.categories.issue.emptyName", bundle: .module)
        case .builtInCategory:
            LocalizedStringResource("settings.categories.issue.builtIn", bundle: .module)
        case .categoryUnavailable:
            LocalizedStringResource("settings.categories.issue.unavailable", bundle: .module)
        case .unknown: nil
        }
    }
}
