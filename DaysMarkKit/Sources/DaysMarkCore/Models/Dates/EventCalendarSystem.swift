//
//  EventCalendarSystem.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum EventCalendarSystem: String, Codable, CaseIterable, Sendable {
    case gregorian
    case chinese
    case islamicUmmAlQura

    public var identifier: Calendar.Identifier {
        switch self {
        case .gregorian: .gregorian
        case .chinese: .chinese
        case .islamicUmmAlQura: .islamicUmmAlQura
        }
    }

    init(supporting identifier: Calendar.Identifier) {
        self =
            switch identifier {
            case .chinese: .chinese
            case .islamicUmmAlQura, .islamic, .islamicCivil, .islamicTabular: .islamicUmmAlQura
            default: .gregorian
            }
    }
}
