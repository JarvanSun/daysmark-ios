//
//  FocusWidgetCard.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI
import WidgetKit

struct FocusWidgetCard: View {
    let row: WidgetRow

    var body: some View {
        WidgetEventHeadline(title: row.title, emphasis: .standard) {
            WidgetPhraseText(row.phrase, direction: row.direction)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
    }
}

#if DEBUG
#Preview("Small", as: .systemSmall) {
    FocusWidget()
} timeline: {
    for entry in PreviewObjectPool().focusEntries {
        entry
    }
}
#endif
