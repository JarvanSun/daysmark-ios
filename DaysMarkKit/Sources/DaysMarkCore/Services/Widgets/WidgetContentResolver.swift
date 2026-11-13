//
//  WidgetContentResolver.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/04.
//

import Foundation
import WidgetKit

struct WidgetContentResolver {
    private let timeZone: TimeZone
    private let locale: Locale
    private let sorter = EventSorter()

    init(timeZone: TimeZone, locale: Locale) {
        self.timeZone = timeZone
        self.locale = locale
    }

    func content(for request: WidgetContentRequest, in store: WidgetStoreContents) -> WidgetContent
    {
        let display = display(for: request, in: store)

        return WidgetContent(
            date: request.now,
            display: display,
            link: link(for: display, of: request)
        )
    }

    func timeline(for request: WidgetContentRequest, in store: WidgetStoreContents)
        -> [WidgetContent]
    {
        WidgetTimelinePlanner(timeZone: timeZone)
            .entryDates(from: request.now, events: store.events(relevantTo: request.source))
            .map { WidgetContentRequest(source: request.source, family: request.family, now: $0) }
            .map { content(for: $0, in: store) }
    }

    func placeholder(titled title: String, for request: WidgetContentRequest) -> WidgetContent {
        let row = placeholderRow(titled: title, at: request.now)
        let display: WidgetDisplay =
            switch (request.source, listLimit(for: request.family)) {
            case (.category, _?), (.allEvents, _?): .list([row])
            default: .event(row)
            }

        return WidgetContent(date: request.now, display: display, link: .collection(.all))
    }
}

// MARK: - Private

private extension WidgetContentResolver {
    var placeholderID: CountdownEvent.ID {
        UUID(
            uuid: (
                0xA1, 0x5B, 0x23, 0xC4, 0xBA, 0x7E, 0x4D, 0x40,
                0xB9, 0x3F, 0x5B, 0x11, 0x3D, 0xB9, 0xB1, 0x20
            )
        )
    }

    var placeholderDayCount: DayCount { DayCount(days: 12, direction: .upcoming) }

    var secondsPerDay: TimeInterval { 86_400 }

    func display(for request: WidgetContentRequest, in store: WidgetStoreContents) -> WidgetDisplay
    {
        let events = store.events.filter {
            $0.deletedAt == nil && $0.permanentDeletionRequestedAt == nil
        }

        return switch request.source {
        case .automaticFocus: focus(among: events, selected: store.focusedEventID, at: request.now)
        case .event(let id): event(id, among: events, at: request.now)
        case .category(let id): category(id, of: store.categories, among: events, for: request)
        case .allEvents: list(events, for: request)
        }
    }

    func focus(among events: [CountdownEvent], selected: CountdownEvent.ID?, at now: Date)
        -> WidgetDisplay
    {
        let focus = sorter.focus(
            in: events,
            now: now,
            userTimeZone: timeZone,
            focusedEventID: selected
        )

        guard let focus else { return .unavailable(.noEvents) }

        return .event(row(for: focus, at: now))
    }

    func event(_ id: CountdownEvent.ID?, among events: [CountdownEvent], at now: Date)
        -> WidgetDisplay
    {
        guard let id, let event = events.first(where: { $0.id == id }) else {
            return .unavailable(.missingSource)
        }

        let counted = sorter.counted([event], now: now, userTimeZone: timeZone)

        guard let first = counted.first else { return .unavailable(.missingSource) }

        return .event(row(for: first, at: now))
    }

    func category(
        _ id: EventCategory.ID?,
        of categories: [EventCategory],
        among events: [CountdownEvent],
        for request: WidgetContentRequest
    ) -> WidgetDisplay {
        guard let id, categories.contains(where: { $0.id == id && $0.deletedAt == nil }) else {
            return .unavailable(.missingSource)
        }

        return list(events.filter { $0.categoryID == id }, for: request)
    }

    func list(_ events: [CountdownEvent], for request: WidgetContentRequest) -> WidgetDisplay {
        let sorted = sorter.sorted(events, now: request.now, userTimeZone: timeZone)

        guard let first = sorted.first else { return .unavailable(.noEvents) }

        return switch listLimit(for: request.family) {
        case let limit?: .list(sorted.prefix(limit).map { row(for: $0, at: request.now) })
        case nil: .event(row(for: first, at: request.now))
        }
    }

    func listLimit(for family: WidgetFamily) -> Int? {
        switch family {
        case .systemMedium: 3
        case .systemLarge: 6
        default: nil
        }
    }

    func row(for count: EventDayCount, at now: Date) -> WidgetRow {
        WidgetRow(
            id: count.id,
            title: count.event.title,
            phrase: count.relativeTimePhrase(at: now, userTimeZone: timeZone, locale: locale),
            dateText: OccurrenceDateFormat(now: now, userTimeZone: timeZone, locale: locale)
                .text(for: count),
            direction: count.dayCount.direction
        )
    }

    func placeholderRow(titled title: String, at now: Date) -> WidgetRow {
        let date = now.addingTimeInterval(TimeInterval(placeholderDayCount.days) * secondsPerDay)

        return WidgetRow(
            id: placeholderID,
            title: title,
            phrase: RelativeTimePhrase(placeholderDayCount),
            dateText: date.formatted(
                Date.FormatStyle(locale: locale, timeZone: timeZone).month(.abbreviated).day()
            ),
            direction: placeholderDayCount.direction
        )
    }

    func link(for display: WidgetDisplay, of request: WidgetContentRequest) -> AppRequest {
        switch (display, request.source) {
        case (.event(let row), _): row.link
        case (_, .automaticFocus), (_, .allEvents): .collection(.all)
        case (_, .event(let id)): id.map(AppRequest.event) ?? .widgets
        case (_, .category(let id)): id.map(AppRequest.category) ?? .widgets
        }
    }
}
