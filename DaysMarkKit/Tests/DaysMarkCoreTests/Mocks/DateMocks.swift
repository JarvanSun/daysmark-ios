//
//  DateMocks.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

extension Date {
    static var mockNow: Date { Date(timeIntervalSince1970: 1_800_000_000) }

    static func mock(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 12,
        in timeZone: TimeZone = .mockUTC
    ) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}

extension TimeZone {
    static var mockUTC: TimeZone { TimeZone(secondsFromGMT: 0)! }

    static var mockTokyo: TimeZone { TimeZone(identifier: "Asia/Tokyo")! }

    static var mockBerlin: TimeZone { TimeZone(identifier: "Europe/Berlin")! }

    static var mockRiyadh: TimeZone { TimeZone(identifier: "Asia/Riyadh")! }
}

extension Locale {
    static var mockAmericanEnglish: Locale { Locale(identifier: "en_US") }
}

extension UUID {
    static var mockSeedID: UUID {
        UUID(uuidString: "9A0B7C3D-1111-4B22-8C33-000000000001")!
    }

    static var mockFocusSelectionID: UUID {
        UUID(uuidString: "F0C00000-0000-4000-8000-000000000004")!
    }

    static var mockFocusRootGroupID: UUID {
        UUID(uuidString: "F0C00000-0000-4000-8000-000000000010")!
    }
}
