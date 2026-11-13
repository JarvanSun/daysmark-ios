//
//  ListWidgetEvent.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI
import WidgetKit

struct ListWidgetEvent: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.widgetFamily) private var family

    let row: WidgetRow

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceCompact) {
            WidgetEventHeadline(title: row.title, emphasis: emphasis) {
                WidgetPhraseText(row.phrase, direction: row.direction)
            }

            if let date = row.dateText {
                Text(date)
                    .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.widgetCaption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
    }

    private var emphasis: WidgetEventEmphasis {
        switch family {
        case .systemMedium: .compact
        default: .prominent
        }
    }
}

#if DEBUG
#Preview("Large", as: .systemLarge) {
    ListWidget()
} timeline: {
    for entry in PreviewObjectPool().listEntries {
        entry
    }
}
#endif
