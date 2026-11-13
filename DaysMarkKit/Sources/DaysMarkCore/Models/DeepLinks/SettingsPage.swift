//
//  SettingsPage.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum SettingsPage: Hashable, Sendable {
    case root
    case widgets
    case recentlyDeleted(highlighting: UUID?)
}
