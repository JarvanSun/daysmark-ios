//
//  EventTimeSemantics.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum EventTimeSemantics: String, Codable, CaseIterable, Sendable {
    case floatingAllDay
    case fixedInstant
    case floatingLocalTime
}
