//
//  EventAppearance.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SunUserInterface
import SwiftUI

nonisolated public enum EventAppearance: String, CaseIterable, ImageStyling, Identifiable, Sendable
{
    case star
    case gift
    case heart
    case airplane
    case graduationCap = "graduationcap"
    case birthdayCake = "birthday.cake"
    case briefcase
    case house
    case running = "figure.run"
    case book
    case calendar

    public init(storedKey: String) {
        self = Self(rawValue: storedKey) ?? .calendar
    }

    public var id: String { rawValue }

    public var name: String {
        switch self {
        case .star: "EventAppearanceStar"
        case .gift: "EventAppearanceGift"
        case .heart: "EventAppearanceHeart"
        case .airplane: "EventAppearanceAirplane"
        case .graduationCap: "EventAppearanceGraduation"
        case .birthdayCake: "EventAppearanceCake"
        case .briefcase: "EventAppearanceBriefcase"
        case .house: "EventAppearanceHouse"
        case .running: "EventAppearanceRunning"
        case .book: "EventAppearanceBook"
        case .calendar: "EventAppearanceCalendar"
        }
    }

    public var definingBundle: Bundle { .module }

    public var isSelectable: Bool { label != nil }

    public var label: String? {
        switch self {
        case .star: String(localized: "eventIcon.star", bundle: .module)
        case .gift: String(localized: "eventIcon.gift", bundle: .module)
        case .heart: String(localized: "eventIcon.heart", bundle: .module)
        case .airplane: String(localized: "eventIcon.airplane", bundle: .module)
        case .graduationCap: String(localized: "eventIcon.graduationCap", bundle: .module)
        case .birthdayCake: String(localized: "eventIcon.birthdayCake", bundle: .module)
        case .briefcase: String(localized: "eventIcon.briefcase", bundle: .module)
        case .house: String(localized: "eventIcon.house", bundle: .module)
        case .running: String(localized: "eventIcon.running", bundle: .module)
        case .book: String(localized: "eventIcon.book", bundle: .module)
        case .calendar: nil
        }
    }

    public var symbol: DaysMarkImage {
        switch self {
        case .star: .star
        case .gift: .gift
        case .heart: .heart
        case .airplane: .airplane
        case .graduationCap: .graduationcap
        case .birthdayCake: .birthdayCake
        case .briefcase: .briefcase
        case .house: .house
        case .running: .figureRun
        case .book: .book
        case .calendar: .calendar
        }
    }

    var opticalScale: CGFloat {
        switch self {
        case .star: 1.169
        case .gift: 1.052
        case .heart: 1.089
        case .airplane: 1.248
        case .graduationCap: 0.934
        case .birthdayCake: 0.954
        case .briefcase: 0.921
        case .house: 0.946
        case .running: 0.894
        case .book: 0.947
        case .calendar: 0.914
        }
    }
}

#if DEBUG
#Preview("Event appearances") {
    @Previewable @Environment(\.dimensions) var dimensions

    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: dimensions.minimumTapTarget))]) {
            ForEach(EventAppearance.allCases) { appearance in
                EventIcon(appearance, size: dimensions.eventIconColumnWidth)
            }
        }
        .padding()
    }
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
