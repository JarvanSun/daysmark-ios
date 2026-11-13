//
//  ListWidgetView.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SwiftUI
import WidgetKit

struct ListWidgetView: View {
    let entry: WidgetEntry

    var body: some View {
        content
            .widgetURL(entry.content.link.url)
            .containerBackground(for: .widget) { DaysMarkColor.canvas.color }
    }

    @ViewBuilder private var content: some View {
        switch entry.content.display {
        case .list(let rows): ListWidgetRows(rows: rows)
        case .event(let row): ListWidgetEvent(row: row)
        case .unavailable(let reason):
            WidgetNotice(title: reason.title, detail: reason.detail, symbol: reason.symbol)
        }
    }
}
