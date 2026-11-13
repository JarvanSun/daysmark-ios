//
//  CalendarExtensions.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension Calendar {
    public func strictDate(from components: DateComponents) -> Date? {
        guard components.year != nil, components.month != nil, components.day != nil,
            let date = date(from: components)
        else { return nil }

        let readBack = dateComponents(
            [.era, .year, .month, .day, .hour, .minute, .second],
            from: date
        )
        guard readBack.year == components.year,
            readBack.month == components.month,
            readBack.day == components.day,
            components.era == nil || readBack.era == components.era,
            components.hour == nil || readBack.hour == components.hour,
            components.minute == nil || readBack.minute == components.minute,
            components.second == nil || readBack.second == components.second,
            components.isLeapMonth == nil
                || readBack.isLeapMonth == components.isLeapMonth
        else { return nil }
        return date
    }
}
