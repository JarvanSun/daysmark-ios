//
//  EventCategory.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/07/25.
//

import Foundation
import SwiftData

@Model
public final class EventCategory {
    public internal(set) var id: UUID = UUID()

    var recordID: UUID = UUID()

    public internal(set) var name: String = ""

    public internal(set) var icon: String = ""

    var builtInKindRaw: String?
    public internal(set) var sortOrder: Int = 0
    public internal(set) var deletedAt: Date?

    @Relationship(deleteRule: .nullify, inverse: \CountdownEvent.category)
    public internal(set) var events: [CountdownEvent]?

    public init(
        id: UUID = UUID(),
        recordID: UUID = UUID(),
        name: String = "",
        icon: String = "",
        builtInKind: BuiltInCategory? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.recordID = recordID
        self.name = name
        self.icon = icon
        self.builtInKindRaw = builtInKind?.rawValue
        self.sortOrder = sortOrder
    }

    public convenience init(builtIn kind: BuiltInCategory) {
        self.init(
            id: kind.id,
            icon: kind.icon,
            builtInKind: kind,
            sortOrder: kind.sortOrder
        )
    }

    public var builtInKind: BuiltInCategory? {
        builtInKindRaw.flatMap(BuiltInCategory.init(rawValue:))
    }

    public var isBuiltIn: Bool { builtInKindRaw != nil }

    public var displayName: String {
        builtInKind?.displayName ?? name
    }
}

public enum BuiltInCategory: String, CaseIterable, Sendable {
    case important
    case birthday
    case anniversary

    public var id: UUID {
        switch self {
        case .important: UUID(fixedGroup: 0x0000_0000, number: 0x01)
        case .birthday: UUID(fixedGroup: 0x0000_0000, number: 0x02)
        case .anniversary: UUID(fixedGroup: 0x0000_0000, number: 0x03)
        }
    }

    public var displayName: String {
        switch self {
        case .important: String(localized: "category.important", bundle: .module)
        case .birthday: String(localized: "category.birthday", bundle: .module)
        case .anniversary: String(localized: "category.anniversary", bundle: .module)
        }
    }

    public var icon: String {
        switch self {
        case .important: "star"
        case .birthday: "birthday.cake"
        case .anniversary: "heart"
        }
    }

    public var sortOrder: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
