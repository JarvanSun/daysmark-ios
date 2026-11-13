//
//  SettingsGroup.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI

public struct SettingsGroup<Content: View>: View {
    @Environment(\.dimensions) private var dimensions

    private let title: Text?
    private let footnote: Text?
    private let separatorInset: CGFloat
    private let content: () -> Content

    public init(
        _ title: Text? = nil,
        footnote: Text? = nil,
        separatorInset: CGFloat = 0,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.footnote = footnote
        self.separatorInset = separatorInset
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                title
                    .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.sectionTitle)
                    .textCase(.uppercase)
                    .padding(.bottom, dimensions.spaceSmall)
                    .accessibilityAddTraits(.isHeader)
            }

            Group(subviews: content()) { rows in
                ForEach(rows) { row in
                    row

                    if row.id != rows.last?.id {
                        Divider()
                            .padding(.leading, separatorInset)
                    }
                }
            }

            if let footnote {
                footnote
                    .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.footnote)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, dimensions.spaceSmall)
            }
        }
    }
}
