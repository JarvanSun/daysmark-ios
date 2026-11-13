//
//  DetailHeader.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct DetailHeader: View {
    @Environment(\.dimensions) private var dimensions

    let event: EventItem

    var body: some View {
        VStack(spacing: dimensions.spaceCompact) {
            Text(verbatim: event.title)
                .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.detailTitle)
                .multilineTextAlignment(.center)

            Text(verbatim: event.dateWithWeekday)
                .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.supporting)
        }
        .padding(.top, dimensions.spaceLargeSmall)
    }
}
