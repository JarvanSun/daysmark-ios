//
//  PageScrollView.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI

public struct PageScrollView<Content: View>: View {
    @Environment(\.dimensions) private var dimensions

    private let topPadding: CGFloat?
    private let content: () -> Content

    public init(topPadding: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.topPadding = topPadding
        self.content = content
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: dimensions.spaceXXLarge) {
                content()
            }
            .padding(.horizontal, dimensions.pageMargin)
            .padding(.top, topPadding ?? dimensions.spaceSmall)
            .padding(.bottom, dimensions.spaceXXXLarge)
        }
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
    }
}
