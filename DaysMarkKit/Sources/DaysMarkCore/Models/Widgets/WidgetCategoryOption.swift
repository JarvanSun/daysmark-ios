//
//  WidgetCategoryOption.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct WidgetCategoryOption: Identifiable, Equatable, Sendable {
    public let id: EventCategory.ID
    public let name: String
    public let icon: String
}
