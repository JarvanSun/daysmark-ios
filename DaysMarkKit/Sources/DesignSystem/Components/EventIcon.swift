//
//  EventIcon.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/09/05.
//

import SunUserInterface
import SwiftUI

public struct EventIcon: View {
    @Environment(\.colorScheme) private var colorScheme

    private let appearance: EventAppearance
    private let size: CGFloat

    public init(_ appearance: EventAppearance, size: CGFloat) {
        self.appearance = appearance
        self.size = size
    }

    public var body: some View {
        Image(style: appearance)
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .saturation(saturation)
            .brightness(brightness)
            .frame(width: size, height: size)
            .scaleEffect(appearance.opticalScale)
            .accessibilityHidden(true)
    }

    private var saturation: Double {
        colorScheme == .dark ? 0.72 : 0.82
    }

    private var brightness: Double {
        colorScheme == .dark ? 0.08 : 0
    }
}

#if DEBUG
#Preview {
    @Previewable @Environment(\.dimensions) var dimensions

    HStack(spacing: dimensions.spaceMedium) {
        EventIcon(.birthdayCake, size: dimensions.eventIconColumnWidth)

        EventIcon(.calendar, size: dimensions.eventIconColumnWidth)

        EventIcon(
            EventAppearance(storedKey: "unknown.legacy.key"),
            size: dimensions.eventIconColumnWidth
        )
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
