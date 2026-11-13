//
//  DaysMarkImage.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SunUserInterface
import SwiftUI

nonisolated public enum DaysMarkImage: String, CaseIterable, ImageStyling, Sendable {
    case arrowClockwise = "arrow.clockwise"
    case arrowUpForward = "arrow.up.forward"
    case bell = "bell"
    case bellBadge = "bell.badge"
    case calendar = "calendar"
    case calendarBadgeClock = "calendar.badge.clock"
    case calendarBadgeExclamationmark = "calendar.badge.exclamationmark"
    case calendarBadgePlus = "calendar.badge.plus"
    case checkmark = "checkmark"
    case checkmarkCircle = "checkmark.circle"
    case checkmarkCircleFill = "checkmark.circle.fill"
    case chevronBackward = "chevron.backward"
    case chevronForward = "chevron.forward"
    case circle = "circle"
    case clock = "clock"
    case ellipsisCircle = "ellipsis.circle"
    case exclamationmarkTriangle = "exclamationmark.triangle"
    case flag = "flag"
    case folder = "folder"
    case gear = "gear"
    case gearshape = "gearshape"
    case globe = "globe"
    case listBullet = "list.bullet"
    case magnifyingglass = "magnifyingglass"
    case pencil = "pencil"
    case personCropCircleBadgePlus = "person.crop.circle.badge.plus"
    case photo = "photo"
    case pin = "pin"
    case pinFill = "pin.fill"
    case pinSlash = "pin.slash"
    case plus = "plus"
    case plusCircle = "plus.circle"
    case rectangle3Group = "rectangle.3.group"
    case `repeat` = "repeat"
    case scope = "scope"
    case squareAndArrowDown = "square.and.arrow.down"
    case squareAndArrowUp = "square.and.arrow.up"
    case star = "star"
    case target = "target"
    case trash = "trash"
    case tray = "tray"
    case waveform = "waveform"
    case xmark = "xmark"
    case gift = "gift"
    case heart = "heart"
    case airplane = "airplane"
    case graduationcap = "graduationcap"
    case birthdayCake = "birthday.cake"
    case briefcase = "briefcase"
    case house = "house"
    case figureRun = "figure.run"
    case book = "book"

    public var definingBundle: Bundle { .module }
}

#if DEBUG
#Preview("Images") {
    @Previewable @Environment(\.dimensions) var dimensions

    ScrollView {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            ForEach(DaysMarkImage.allCases, id: \.self) { image in
                Label(Text(verbatim: image.rawValue), symbol: image)
                    .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.rowTitle)
            }
        }
        .padding()
    }
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
