//
//  SpecialNodeChoiceRow.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct SpecialNodeChoiceRow: View {
    let choice: SpecialNodeChoice
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            LabeledContent {
                if choice.isSelected {
                    Image(style: DaysMarkImage.checkmark)
                        .textStyle(DaysMarkColor.tint, DaysMarkFont.selectionMark)
                        .accessibilityHidden(true)
                }
            } label: {
                Text(choice.preset.title)
                    .foregroundStyle(DaysMarkColor.textPrimary.color)

                if let detail = choice.detail {
                    detail
                }
            }
            .opacity(choice.opacity)
        }
        .disabled(!choice.isEnabled)
        .accessibilityValue(Text(choice.accessibilityValue))
        .accessibilityAddTraits(choice.accessibilityTraits)
        .accessibilityLabel(Text(choice.preset.title))
    }
}

#if DEBUG
#Preview {
    Form {
        ForEach(PreviewObjectPool().specialNodeChoices) { choice in
            SpecialNodeChoiceRow(choice: choice, onToggle: {})
        }
    }
}
#endif
