//
//  FocusWidgetView.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SwiftUI
import WidgetKit

struct FocusWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: WidgetEntry

    var body: some View {
        content
            .widgetURL(entry.content.link.url)
            .containerBackground(for: .widget) { background }
    }

    @ViewBuilder private var content: some View {
        switch (entry.content.display, family) {
        case (.unavailable(let reason), _):
            WidgetNotice(title: reason.title, detail: reason.detail, symbol: reason.symbol)
        case (.event(let row), .accessoryCircular): FocusWidgetCircular(row: row)
        case (.event(let row), .accessoryRectangular): FocusWidgetRectangular(row: row)
        case (.event(let row), .accessoryInline): FocusWidgetInline(row: row)
        case (.event(let row), _): FocusWidgetCard(row: row)
        case (.list, _): EmptyView()
        }
    }

    @ViewBuilder private var background: some View {
        switch family {
        case .accessoryCircular: AccessoryWidgetBackground()
        case .accessoryRectangular, .accessoryInline: Color.clear
        default: DaysMarkColor.canvas.color
        }
    }
}
