//
//  FocusWidget.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import SwiftUI
import WidgetKit

struct FocusWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.focus.rawValue,
            intent: CountdownWidgetConfigurationIntent.self,
            provider: FocusWidgetProvider()
        ) { entry in
            FocusWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.focus.name")
        .description("widget.focus.description")
        .supportedFamilies([
            .systemSmall,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
