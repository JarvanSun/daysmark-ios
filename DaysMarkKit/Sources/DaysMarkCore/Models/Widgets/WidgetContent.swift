//
//  WidgetContent.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct WidgetContent: Equatable, Sendable {
    public let date: Date
    public let display: WidgetDisplay
    public let link: AppRequest

    public init(date: Date, display: WidgetDisplay, link: AppRequest) {
        self.date = date
        self.display = display
        self.link = link
    }
}

public enum WidgetDisplay: Equatable, Sendable {
    case event(WidgetRow)
    case list([WidgetRow])
    case unavailable(WidgetUnavailability)
}

public enum WidgetUnavailability: Equatable, Sendable {
    case noEvents
    case missingSource
}
