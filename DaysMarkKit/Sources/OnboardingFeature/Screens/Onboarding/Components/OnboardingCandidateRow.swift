//
//  OnboardingCandidateRow.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct OnboardingCandidateRow: View {
    @Environment(\.dimensions) private var dimensions

    let candidate: OnboardingContent.Candidate
    let onToggle: () -> Void

    var body: some View {
        if candidate.showsSeparator {
            Divider()
                .padding(.leading, dimensions.iconColumnWidth + dimensions.spaceMedium)
        }

        Button(action: onToggle) {
            HStack(alignment: .firstTextBaseline, spacing: dimensions.spaceMedium) {
                Image(style: candidate.markSymbol)
                    .textStyle(candidate.markColor, DaysMarkFont.prominentSymbol)
                    .frame(width: dimensions.iconColumnWidth)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: dimensions.rowLineSpacing) {
                    Text(candidate.seed.title)
                        .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.rowTitle)

                    if let note = candidate.seed.note {
                        Text(note)
                            .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.rowSecondary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: dimensions.spaceSmall)

                if let dayCount = candidate.dayCount {
                    CountdownPhrase(count: dayCount, font: .rowPhrase)
                }
            }
            .padding(.vertical, dimensions.spaceSmall)
            .frame(minHeight: dimensions.minimumTapTarget)
            .contentShape(Rectangle())
            .opacity(candidate.opacity)
        }
        .buttonStyle(.daysmark(.row))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(candidate.accessibilityTraits)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 0) {
        ForEach(PreviewObjectPool().candidates) { candidate in
            OnboardingCandidateRow(candidate: candidate, onToggle: {})
        }
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
