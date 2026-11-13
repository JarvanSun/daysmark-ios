//
//  WidgetNotice.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI
import WidgetKit

public struct WidgetNotice: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.widgetFamily) private var family

    private let title: String
    private let detail: String
    private let symbol: DaysMarkImage

    public init(title: String, detail: String, symbol: DaysMarkImage) {
        self.title = title
        self.detail = detail
        self.symbol = symbol
    }

    public var body: some View {
        ViewThatFits(in: .vertical) {
            notice

            Text(title)
                .font(DaysMarkFont.widgetCaption)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(title). \(detail)"))
    }

    private var notice: some View {
        VStack(spacing: dimensions.spaceSmall) {
            Spacer(minLength: 0)

            VStack(spacing: dimensions.spaceCompact) {
                symbolImage

                Text(title)
                    .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.widgetTitle)

                detailText
            }
            .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var symbolImage: some View {
        if showsSymbol {
            Image(style: symbol)
                .textStyle(DaysMarkColor.tint, DaysMarkFont.prominentSymbol)
                .widgetAccentable()
        }
    }

    private var showsSymbol: Bool {
        switch family {
        case .accessoryCircular, .accessoryRectangular, .accessoryInline: true
        default: false
        }
    }

    @ViewBuilder
    private var detailText: some View {
        if showsDetail {
            Text(detail)
                .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.widgetCaption)
        }
    }

    private var showsDetail: Bool {
        switch family {
        case .accessoryCircular, .accessoryInline: false
        default: true
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.dimensions) var dimensions

    let pool = PreviewObjectPool()

    VStack(spacing: dimensions.spaceLargeSmall) {
        ForEach(pool.widgetNotices) { notice in
            WidgetNotice(
                title: notice.title,
                detail: notice.detail,
                symbol: notice.symbol
            )
        }
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
