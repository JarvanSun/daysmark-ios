//
//  CountdownWidgetConfigurationIntent.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore

struct CountdownWidgetConfigurationIntent: WidgetConfigurationIntent, Sendable {
    static let title: LocalizedStringResource = "widget.focus.configuration.title"
    static let description = IntentDescription("widget.focus.configuration.description")

    @Parameter(title: "widget.focus.parameter.source", default: .automaticFocus)
    var source: CountdownWidgetSource

    @Parameter(title: "widget.focus.parameter.event")
    var event: CountdownWidgetEventEntity?

    @Parameter(title: "widget.focus.parameter.category")
    var category: CountdownWidgetCategoryEntity?

    static var parameterSummary: some ParameterSummary {
        When(\CountdownWidgetConfigurationIntent.$source, .equalTo, .event) {
            Summary("\(\.$source) \(\.$event)")
        } otherwise: {
            When(\CountdownWidgetConfigurationIntent.$source, .equalTo, .category) {
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
