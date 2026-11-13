//
//  ListWidgetProvider.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import WidgetKit

struct ListWidgetProvider: AppIntentTimelineProvider {
    private let reader = WidgetContentReader()

    func placeholder(in context: Context) -> WidgetEntry {
        let request = WidgetContentRequest(source: .allEvents, family: context.family, now: .now)

        return WidgetEntry(content: reader.placeholder(for: request))
    }

    func snapshot(for configuration: CountdownListWidgetConfigurationIntent, in context: Context)
        async -> WidgetEntry
    {
        let request = WidgetContentRequest(
            source: configuration.contentSource,
            family: context.family,
            now: .now
        )

        return switch context.isPreview {
        case true: WidgetEntry(content: reader.placeholder(for: request))
        case false: WidgetEntry(content: await reader.content(for: request))
        }
    }

    func timeline(for configuration: CountdownListWidgetConfigurationIntent, in context: Context)
        async -> Timeline<WidgetEntry>
    {
        let request = WidgetContentRequest(
            source: configuration.contentSource,
            family: context.family,
            now: .now
        )
        let entries = await reader.timeline(for: request).map(WidgetEntry.init(content:))

        return Timeline(entries: entries, policy: .after(entries.last?.date ?? request.now))
    }
}
