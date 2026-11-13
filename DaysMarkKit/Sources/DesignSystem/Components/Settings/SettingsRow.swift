//
//  SettingsRow.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI

public struct SettingsRow<Accessory: View>: View {
    @Environment(\.dimensions) private var dimensions

    private let title: Text
    private let subtitle: Text?
    private let symbol: DaysMarkImage?
    private let value: Text?
    private let showsDisclosure: Bool
    private let accessory: () -> Accessory

    public init(
        _ title: Text,
        subtitle: Text? = nil,
        symbol: DaysMarkImage? = nil,
        value: Text? = nil,
        showsDisclosure: Bool = false,
        @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.value = value
        self.showsDisclosure = showsDisclosure
        self.accessory = accessory
    }

    public var body: some View {
        HStack(spacing: dimensions.spaceMedium) {
            if let symbol {
                SettingsRowIcon(symbol: symbol)
            }

            VStack(alignment: .leading, spacing: dimensions.rowLineSpacing) {
                title.textStyle(DaysMarkColor.textPrimary, DaysMarkFont.rowTitle)

                if let subtitle {
                    subtitle.textStyle(DaysMarkColor.textSecondary, DaysMarkFont.rowSecondary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: dimensions.spaceMedium)

            if let value {
                value
                    .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.rowTitle)
                    .multilineTextAlignment(.trailing)
            }

            accessory()

            if showsDisclosure {
                Image(style: DaysMarkImage.chevronForward)
                    .textStyle(DaysMarkColor.textTertiary, DaysMarkFont.disclosure)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, dimensions.spaceMedium)
        .frame(minHeight: dimensions.rowMinimumHeight)
        .contentShape(Rectangle())
    }
}

public struct SettingsLabel: View {
    @Environment(\.dimensions) private var dimensions

    private let title: Text
    private let symbol: DaysMarkImage?

    public init(title: Text, symbol: DaysMarkImage? = nil) {
        self.title = title
        self.symbol = symbol
    }

    public var body: some View {
        HStack(spacing: dimensions.spaceMedium) {
            if let symbol {
                SettingsRowIcon(symbol: symbol)
            } else {
                Color.clear
                    .frame(width: dimensions.iconColumnWidth, height: 0)
            }

            title.textStyle(DaysMarkColor.textPrimary, DaysMarkFont.rowTitle)
        }
    }
}

private struct SettingsRowIcon: View {
    @Environment(\.dimensions) private var dimensions

    let symbol: DaysMarkImage

    var body: some View {
        Image(style: symbol)
            .symbolVariant(.none)
            .textStyle(DaysMarkColor.tint, DaysMarkFont.rowIcon)
            .frame(width: dimensions.iconColumnWidth)
            .accessibilityHidden(true)
    }
}
