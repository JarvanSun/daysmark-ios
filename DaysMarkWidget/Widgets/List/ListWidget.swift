//
//  ListWidget.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import SwiftUI
import WidgetKit

struct ListWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.list.rawValue,
            intent: CountdownListWidgetConfigurationIntent.self,
            provider: ListWidgetProvider()
        ) { entry in
            ListWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.list.name")
        .description("widget.list.description")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
