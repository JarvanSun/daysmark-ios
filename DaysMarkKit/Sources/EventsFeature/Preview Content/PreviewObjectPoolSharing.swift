//
//  PreviewObjectPoolSharing.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore
import DesignSystem

extension PreviewObjectPool {
    var shareContents: [EventShareContent] {
        [
            EventShareContent(
                title: eventTitle,
                relativeTime: "in 18 days",
                absoluteTime: "September 23, 2026",
                calendarName: nil,
                referenceDateText: "As of Sep 5, 2026 at 12:00 PM",
                appearance: EventAppearance(storedKey: "birthday.cake"),
                direction: .upcoming,
                category: nil
            ),
            EventShareContent(
                title: "Unser erster gemeinsamer Tag in unserem neuen Zuhause",
                relativeTime: "Seit 1.024 Tagen",
                absoluteTime: "15. November 2023",
                calendarName: nil,
                referenceDateText: "Stand: 5. Sept. 2026, 12:00",
                appearance: EventAppearance(storedKey: "house"),
                direction: .past,
                category: "Jahrestage"
            ),
        ]
    }
}
#endif
