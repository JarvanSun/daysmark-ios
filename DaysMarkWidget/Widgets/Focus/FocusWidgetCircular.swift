//
//  FocusWidgetCircular.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI
import WidgetKit

struct FocusWidgetCircular: View {
    let row: WidgetRow

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 0) {
                Image(style: DaysMarkImage.calendar)
                    .font(DaysMarkFont.widgetSymbol)

                Text(verbatim: row.phrase.number ?? row.phrase.text)
                    .font(DaysMarkFont.widgetTitle)
                    .minimumScaleFactor(0.6)
            }
            .widgetAccentable()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
    }
}

#if DEBUG
#Preview("Circular", as: .accessoryCircular) {
    FocusWidget()
} timeline: {
    for entry in PreviewObjectPool().focusEntries {
        entry
    }
}
#endif
