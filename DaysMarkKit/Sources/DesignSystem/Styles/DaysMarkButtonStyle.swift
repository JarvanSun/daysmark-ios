//
//  DaysMarkButtonStyle.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI

public struct DaysMarkButtonStyle: PrimitiveButtonStyle {
    private let kind: Kind

    public init(kind: Kind) {
        self.kind = kind
    }

    public func makeBody(configuration: Configuration) -> some View {
        switch kind {
        case .primary: prominent(Button(configuration))
        case .bar: prominent(Button(configuration)).controlSize(.large)
        case .secondary, .caution: bordered(Button(configuration))
        case .row: Button(configuration).buttonStyle(.plain)
        }
    }

    private func prominent(_ button: Button<Configuration.Label>) -> some View {
        button
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(kind.tint.color)
            .foregroundStyle(DaysMarkColor.textOnTint.color)
    }

    private func bordered(_ button: Button<Configuration.Label>) -> some View {
        button
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .tint(kind.tint.color)
    }
}

extension DaysMarkButtonStyle {
    public enum Kind: CaseIterable, Sendable {
        case primary
        case bar
        case secondary
        case caution
        case row

        var tint: DaysMarkColor {
            switch self {
            case .caution: .caution
            case .primary, .bar, .secondary, .row: .tint
            }
        }
    }
}

#if DEBUG
#Preview("Buttons") {
    @Previewable @Environment(\.dimensions) var dimensions

    ScrollView {
        VStack(spacing: dimensions.spaceMedium) {
            ForEach(DaysMarkButtonStyle.Kind.allCases, id: \.self) { kind in
                ForEach([true, false], id: \.self) { isEnabled in
                    Button(action: {}) {
                        Text(verbatim: "\(kind)\(isEnabled ? "" : ", disabled")")
                    }
                    .buttonStyle(.daysmark(kind))
                    .disabled(!isEnabled)
                }
            }
        }
        .padding()
    }
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
