//
//  CategoryEditorTarget.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation

nonisolated enum CategoryEditorTarget: Hashable, Sendable {
    case new
    case existing(id: EventCategory.ID, name: String, icon: String)

    var categoryID: EventCategory.ID? {
        switch self {
        case .new: nil
        case .existing(let id, _, _): id
        }
    }

    var name: String {
        switch self {
        case .new: ""
        case .existing(_, let name, _): name
        }
    }

    var icon: String {
        switch self {
        case .new: EventAppearance.star.rawValue
        case .existing(_, _, let icon): icon
        }
    }
}

extension CategoryEditorTarget {
    var title: LocalizedStringResource {
        switch self {
        case .new: LocalizedStringResource("settings.categories.editor.title.new", bundle: .module)
        case .existing:
            LocalizedStringResource("settings.categories.editor.title.edit", bundle: .module)
        }
    }
}
