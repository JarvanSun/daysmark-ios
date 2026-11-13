//
//  FocusWidgetRectangular.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI
import WidgetKit

struct FocusWidgetRectangular: View {
    @Environment(\.dimensions) private var dimensions

    let row: WidgetRow

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.accessoryLineSpacing) {
            Text(row.title)
                .font(DaysMarkFont.widgetTitle)
                .lineLimit(2)

            Text(verbatim: row.phrase.text)
                .font(DaysMarkFont.widgetCaption)
                .widgetAccentable()
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
    }
}

#if DEBUG
#Preview("Rectangular", as: .accessoryRectangular) {
    FocusWidget()
} timeline: {
    for entry in PreviewObjectPool().focusEntries {
        entry
    }
}
#endif
