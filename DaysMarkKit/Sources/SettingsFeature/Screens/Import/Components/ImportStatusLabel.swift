//
//  ImportStatusLabel.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct ImportStatusLabel: View {
    let decision: ImportDecision

    var body: some View {
        Label {
            Text(decision.status)
        } icon: {
            icon
        }
        .textStyle(decision.statusColor, DaysMarkFont.footnoteEmphasized)
    }

    @ViewBuilder
    private var icon: some View {
        if let symbol = decision.statusSymbol {
            Image(style: symbol)
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.dimensions) var dimensions

    VStack(alignment: .leading, spacing: dimensions.spaceSmall) {
        ForEach(PreviewObjectPool().importDecisions, id: \.self) { decision in
            ImportStatusLabel(decision: decision)
        }
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
