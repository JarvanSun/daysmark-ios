//
//  PreviewObjectPool.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import SunUserInterface
import SwiftUI

struct PreviewObjectPool {
    var reminderMinuteOfDay: Int { 9 * 60 + 30 }

    var rowTitle: String { "Keep the dates that matter close" }

    var issue: Issue? {
        Issue(title: resource("Couldn’t save"), message: resource("A category needs a name."))
    }

    private func resource(_ text: String) -> LocalizedStringResource {
        LocalizedStringResource(String.LocalizationValue(text))
    }

    var landscapeMarkers: [LandscapeMarker] {
        [
            LandscapeMarker(days: 2, isPast: true),
            LandscapeMarker(days: 40, isPast: true),
            LandscapeMarker(days: 900, isPast: true),
            LandscapeMarker(days: 1, isPast: false),
            LandscapeMarker(days: 12, isPast: false),
            LandscapeMarker(days: 30, isPast: false),
            LandscapeMarker(days: 118, isPast: false),
            LandscapeMarker(days: 500, isPast: false),
        ]
    }

    var widgetNotices: [Notice] {
        [
            Notice(
                title: "No Events",
                detail: "This source has no events yet.",
                symbol: .calendarBadgePlus
            ),
            Notice(
                title: "Source Unavailable",
                detail: "Choose this widget’s source again.",
                symbol: .exclamationmarkTriangle
            ),
        ]
    }
}

extension PreviewObjectPool {
    struct Issue: IssuePresenting {
        let title: LocalizedStringResource
        let message: LocalizedStringResource?
    }

    struct Notice: Identifiable {
        let title: String
        let detail: String
        let symbol: DaysMarkImage

        var id: String { title }
    }
}
#endif
