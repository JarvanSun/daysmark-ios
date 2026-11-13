//
//  TimeOfDayTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Testing

@testable import DaysMarkCore

struct TimeOfDayTests {
    @Test
    func initWithAMinuteOfDayThenSplitsItIntoHourAndMinute() {
        // Given / When
        let time = TimeOfDay(minuteOfDay: 7 * 60 + 5)

        // Then
        #expect(time.hour == 7)
        #expect(time.minute == 5)
    }

    @Test(arguments: [(-1, 0, 0), (99_999, 23, 59)])
    func initWithAMinuteOutsideTheDayThenClampsIt(minuteOfDay: Int, hour: Int, minute: Int) {
        #expect(TimeOfDay(minuteOfDay: minuteOfDay) == TimeOfDay(hour: hour, minute: minute))
    }

    @Test
    func initWithAnHourOutsideTheDayThenClampsIt() {
        #expect(TimeOfDay(hour: 99, minute: 0) == TimeOfDay(hour: 23, minute: 59))
        #expect(TimeOfDay(hour: -5, minute: -5) == TimeOfDay(hour: 0, minute: 0))
    }

    @Test(arguments: [0, 1, 9 * 60, 21 * 60 + 30, 24 * 60 - 1])
    func minuteOfDayThenRoundTrips(minutes: Int) {
        #expect(TimeOfDay(minuteOfDay: minutes).minuteOfDay == minutes)
    }
}
