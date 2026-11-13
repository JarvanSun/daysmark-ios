//
//  FocusWidgetInline.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI
import WidgetKit

struct FocusWidgetInline: View {
    let row: WidgetRow

    var body: some View {
        Text("widget.focus.inline \(row.title) \(row.phrase.text)")
            .accessibilityLabel(Text(verbatim: row.accessibilityLabel))
    }
}

#if DEBUG
#Preview("Inline", as: .accessoryInline) {
    FocusWidget()
} timeline: {
    for entry in PreviewObjectPool().focusEntries {
        entry
    }
}
#endif
