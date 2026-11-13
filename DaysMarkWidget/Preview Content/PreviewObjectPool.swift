//
//  PreviewObjectPool.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore
import Foundation
import DesignSystem

struct PreviewObjectPool {
    var focusEntries: [WidgetEntry] {
        let rows = self.rows

        return [
            content(.event(rows[0]), link: rows[0].link),
            content(.event(rows[3]), link: rows[3].link),
            content(.unavailable(.noEvents), link: .collection(.all)),
            content(.unavailable(.missingSource), link: .widgets),
        ]
        .map(WidgetEntry.init(content:))
    }

    var listEntries: [WidgetEntry] {
        let rows = self.rows

        return [
            content(.list(rows), link: .collection(.all)),
            content(.list(Array(rows.prefix(2))), link: .collection(.all)),
            content(.event(rows[0]), link: rows[0].link),
            content(.unavailable(.noEvents), link: .collection(.all)),
            content(.unavailable(.missingSource), link: .widgets),
        ]
        .map(WidgetEntry.init(content:))
    }

    var rows: [WidgetRow] {
        [
            row(
                "Trip to Berlin with the whole family",
                in: DayCount(days: 12, direction: .upcoming)
            ),
            row("Mia’s birthday", in: DayCount(days: 1, direction: .upcoming)),
            row("Moved into the flat", in: DayCount(days: 126, direction: .past)),
            row("Reise nach Hamburg", in: DayCount(days: 0, direction: .today)),
            row("Graduation", in: DayCount(days: 1024, direction: .past)),
            row("Passport renewal", in: DayCount(days: 300, direction: .upcoming)),
        ]
    }

    var activity: ImportantDateActivityAttributes {
        let id = UUID()

        return ImportantDateActivityAttributes(
            eventID: id,
            presentedTitle: "Flight to Lisbon",
            symbolName: DaysMarkImage.calendar.rawValue,
            deepLink: AppRequest.event(id).url!
        )
    }

    var activityStates: [ImportantDateActivityAttributes.ContentState] {
        [
            ImportantDateActivityAttributes.ContentState(
                targetDate: now.addingTimeInterval(5_400),
                target: .start,
                isTerminal: false
            ),
            ImportantDateActivityAttributes.ContentState(
                targetDate: now.addingTimeInterval(600),
                target: .end,
                isTerminal: false
            ),
            ImportantDateActivityAttributes.ContentState(
                targetDate: now,
                target: .point,
                isTerminal: true
            ),
        ]
    }

    private var now: Date {
        Date(timeIntervalSinceReferenceDate: 816_000_000)
    }

    private var secondsPerDay: TimeInterval {
        86_400
    }

    private func content(_ display: WidgetDisplay, link: AppRequest) -> WidgetContent {
        WidgetContent(date: now, display: display, link: link)
    }

    private func row(_ title: String, in count: DayCount) -> WidgetRow {
        let days = TimeInterval(count.direction == .past ? -count.days : count.days)

        return WidgetRow(
            id: UUID(),
            title: title,
            phrase: RelativeTimePhrase(count),
            dateText: now.addingTimeInterval(days * secondsPerDay)
                .formatted(.dateTime.month(.abbreviated).day()),
            direction: count.direction
        )
    }
}
#endif
