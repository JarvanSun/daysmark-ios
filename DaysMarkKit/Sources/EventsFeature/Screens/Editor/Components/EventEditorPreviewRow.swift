//
//  EventEditorPreviewRow.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/10/07.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct EventEditorPreviewRow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions

    let preview: EditorPreview

    var body: some View {
        HStack(spacing: dimensions.spaceMedium) {
            Text(preview.sentence)
                .font(DaysMarkFont.previewSentence)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 0) {
                preview.number
                    .font(DaysMarkFont.previewNumber)
                    .monospacedDigit()
                    .foregroundColor(preview.tint)
                    .contentTransition(.numericText(countsDown: preview.countsDown))
                    .lineLimit(1)

                if let unit = preview.unit {
                    Text(unit)
                        .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.previewUnit)
                }
            }
        }
        .animation(
            DaysMarkMotion.dayChange.animation(reducingMotion: reduceMotion),
            value: preview.dayCount
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: preview.accessibilityLabel))
    }
}

#if DEBUG
#Preview {
    Form {
        ForEach(PreviewObjectPool().editorPreviews, id: \.title) { preview in
            EventEditorPreviewRow(preview: preview)
        }
    }
}
#endif
