//
//  WidgetRow.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct WidgetRow: Identifiable, Hashable, Sendable {
    public let id: CountdownEvent.ID
    public let title: String
    public let phrase: RelativeTimePhrase
    public let dateText: String?
    public let direction: DayCount.Direction

    public var link: AppRequest { .event(id) }

    public var accessibilityLabel: String {
        [title, phrase.text, dateText].compactMap(\.self).joined(separator: ", ")
    }

    public init(
        id: CountdownEvent.ID,
        title: String,
        phrase: RelativeTimePhrase,
        dateText: String?,
        direction: DayCount.Direction
    ) {
        self.id = id
        self.title = title
        self.phrase = phrase
        self.dateText = dateText
        self.direction = direction
    }
}
