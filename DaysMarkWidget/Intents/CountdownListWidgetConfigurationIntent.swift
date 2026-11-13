//
//  CountdownListWidgetConfigurationIntent.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore

struct CountdownListWidgetConfigurationIntent: WidgetConfigurationIntent, Sendable {
    static let title: LocalizedStringResource = "widget.list.configuration.title"
    static let description = IntentDescription("widget.list.configuration.description")

    @Parameter(title: "widget.list.parameter.source", default: .allEvents)
    var source: CountdownWidgetSource

    @Parameter(title: "widget.list.parameter.event")
    var event: CountdownWidgetEventEntity?

    @Parameter(title: "widget.list.parameter.category")
    var category: CountdownWidgetCategoryEntity?

    static var parameterSummary: some ParameterSummary {
        When(\CountdownListWidgetConfigurationIntent.$source, .equalTo, .event) {
            Summary("\(\.$source) \(\.$event)")
        } otherwise: {
            When(\CountdownListWidgetConfigurationIntent.$source, .equalTo, .category) {
                Summary("\(\.$source) \(\.$category)")
            } otherwise: {
                Summary("\(\.$source)")
            }
        }
    }

    var contentSource: WidgetContentSource {
        source.contentSource(event: event, category: category)
    }
}
