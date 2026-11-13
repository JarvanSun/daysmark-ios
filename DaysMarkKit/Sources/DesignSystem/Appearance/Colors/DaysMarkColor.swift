//
//  DaysMarkColor.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI

nonisolated public enum DaysMarkColor: String, CaseIterable, ColorStyling, Sendable {
    case canvas
    case canvasSecondary
    case textPrimary
    case textSecondary
    case textTertiary
    case textOnTint
    case separator
    case tint
    case tintSoft
    case upcoming
    case past
    case destructive
    case destructiveControl
    case caution
    case landscapePastGround
    case landscapeFutureGround
    case landscapePastFoliage
    case landscapeFutureFoliage

    public var color: Color {
        Color(rawValue, bundle: .module)
    }
}

#if DEBUG
#Preview("Colors") {
    @Previewable @Environment(\.dimensions) var dimensions

    ScrollView {
        VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
            ForEach(DaysMarkColor.allCases, id: \.self) { color in
                HStack(spacing: dimensions.spaceMedium) {
                    RoundedRectangle(cornerRadius: dimensions.cornerRadiusSmall)
                        .fill(color.color)
                        .stroke(
                            DaysMarkColor.separator.color,
                            lineWidth: dimensions.borderWidthXSmall
                        )
                        .frame(
                            width: dimensions.minimumTapTarget,
                            height: dimensions.minimumTapTarget
                        )

                    Text(verbatim: color.rawValue)
                        .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.rowTitle)
                }
            }
        }
        .padding()
    }
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
