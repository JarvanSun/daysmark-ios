//
//  ImportantDateActivityAttributes.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/04.
//

import ActivityKit
import Foundation

public struct ImportantDateActivityAttributes: ActivityAttributes {
    public var eventID: UUID
    public var presentedTitle: String
    public var symbolName: String
    public var deepLink: URL

    public init(eventID: UUID, presentedTitle: String, symbolName: String, deepLink: URL) {
        self.eventID = eventID
        self.presentedTitle = presentedTitle
        self.symbolName = symbolName
        self.deepLink = deepLink
    }
}

extension ImportantDateActivityAttributes {
    public enum Target: String, Codable, Hashable, Sendable {
        case start
        case end
        case point
    }

    public struct ContentState: Codable, Hashable, Sendable {
        var targetTimestamp: TimeInterval
        public var target: Target
        public var isTerminal: Bool

        public init(targetDate: Date, target: Target, isTerminal: Bool) {
            targetTimestamp = targetDate.timeIntervalSince1970
            self.target = target
            self.isTerminal = isTerminal
        }

        public var targetDate: Date { Date(timeIntervalSince1970: targetTimestamp) }
    }
}
