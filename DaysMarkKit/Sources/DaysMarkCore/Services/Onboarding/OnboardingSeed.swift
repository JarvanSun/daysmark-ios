//
//  OnboardingSeed.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation

public enum OnboardingSeed: String, Codable, CaseIterable, Identifiable, Sendable {
    case newYear = "onboarding.new-year.v1"
    case nextMonth = "onboarding.next-month.v1"
    case monthEnd = "onboarding.month-end.v1"
    case birthday = "onboarding.my-birthday.v1"
    case birthDate = "onboarding.my-birth-date.v1"
    case fallbackYearProgress = "onboarding.fallback.year-progress.v1"
    case fallbackNewYear = "onboarding.fallback.new-year.v1"

    public var id: String { rawValue }

    var eventID: UUID {
        UUID(
            uuid: (
                0x9A, 0x0B, 0x7C, 0x3D,
                0x11, 0x11,
                0x4B, 0x22,
                0x8C, 0x33,
                0x00, 0x00, 0x00, 0x00, 0x00, eventNumber
            )
        )
    }

    private var eventNumber: UInt8 {
        switch self {
        case .newYear: 1
        case .nextMonth: 2
        case .monthEnd: 3
        case .birthday: 4
        case .birthDate: 5
        case .fallbackYearProgress: 6
        case .fallbackNewYear: 7
        }
    }
}
