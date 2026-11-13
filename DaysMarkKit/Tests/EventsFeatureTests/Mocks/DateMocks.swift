//
//  DateMocks.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

@testable import EventsFeature

extension Date {
    nonisolated static var mockNow: Date {
        .mock(2030, 9, 10, hour: 12)
    }

    nonisolated static func mock(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 0,
        minute: Int = 0,
        in timeZone: TimeZone = .gmt
    ) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        return calendar.date(
            from: .init(year: year, month: month, day: day, hour: hour, minute: minute)
        )!
    }
}

extension UUID {
    nonisolated static var mockActive: UUID {
        .init(uuidString: "AAAAAAAA-AAAA-4AAA-8AAA-AAAAAAAAAAAA")!
    }

    nonisolated static var mockDeleted: UUID {
        .init(uuidString: "BBBBBBBB-BBBB-4BBB-8BBB-BBBBBBBBBBBB")!
    }

    nonisolated static var mockMissing: UUID {
        .init(uuidString: "CCCCCCCC-CCCC-4CCC-8CCC-CCCCCCCCCCCC")!
    }

    nonisolated static var mockOther: UUID {
        .init(uuidString: "DDDDDDDD-DDDD-4DDD-8DDD-DDDDDDDDDDDD")!
    }
}

extension CurrentTime {
    static func mock(
        now: Date = .mockNow,
        timeZone: TimeZone = .gmt,
        locale: Locale = .init(identifier: "en_US")
    ) -> CurrentTime {
        .init(now: now, timeZone: timeZone, locale: locale)
    }
}
