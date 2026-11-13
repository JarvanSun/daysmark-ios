//
//  WidgetContentRequest.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import WidgetKit

public struct WidgetContentRequest: Sendable {
    public let source: WidgetContentSource
    public let family: WidgetFamily
    public let now: Date

    public init(source: WidgetContentSource, family: WidgetFamily, now: Date) {
        self.source = source
        self.family = family
        self.now = now
    }
}

public enum WidgetContentSource: Equatable, Sendable {
    case automaticFocus
    case event(CountdownEvent.ID?)
    case category(EventCategory.ID?)
    case allEvents
}
