//
//  ListWidgetRow.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct ListWidgetRow: View {
    @Environment(\.dimensions) private var dimensions

    let row: WidgetRow

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.rowLineSpacing) {
            Text(row.title)
                .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.widgetRowTitle)
                .lineLimit(1)

            WidgetPhraseText(row.phrase, direction: row.direction)
                .font(DaysMarkFont.rowPhrase)
                .monospacedDigit()
                .lineLimit(1)
        }
        .padding(.vertical, dimensions.spaceCompact)
        .frame(maxWidth: .infinity, minHeight: dimensions.minimumTapTarget, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(row.accessibilityLabel)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        ForEach(PreviewObjectPool().rows) { row in
            ListWidgetRow(row: row)
        }
    }
    .padding()
}
#endif
