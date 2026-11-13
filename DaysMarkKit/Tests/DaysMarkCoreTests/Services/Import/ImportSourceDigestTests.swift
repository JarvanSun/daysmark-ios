//
//  ImportSourceDigestTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct ImportSourceDigestTests {
    @Test(arguments: [
        (
            ImportedDate.mock(title: "  Mary’s Birthday "),
            "1a5f316bd71065fbda46d04b7a509ffff68bc63306467ef2ff74880cb6ea3212"
        ),
        (
            .mockTimedCalendarEvent,
            "1967ab306de65839ba72d53833875002cc85a64dd6aa5ed057519946e0d9da75"
        ),
        (
            .mock(
                sourceKind: .calendar,
                sourceIdentifier: "calendar-day",
                title: "Conference",
                date: .mock(2027, 1, 2, hour: 0, in: .mockTokyo),
                repeatsYearly: false,
                timeZone: .mockTokyo
            ),
            "276184dd4c1aefc6b94be7c17513a5264150dbf2bb3bb37d67f2eea8c6b98ca8"
        ),
        (
            .mock(
                sourceIdentifier: "lunar-contact",
                title: "Grandma’s Birthday",
                date: .mock(2001, 5, 25),
                calendarSystem: .chinese
            ),
            "0b92ba34bcd6ebb807fe47e367caa33ca21b9bc11b95a2a2cf29adf6e943267a"
        ),
    ])
    func rawValueThenIsTheDigestStoredInSyncedEvents(item: ImportedDate, stored: String) {
        #expect(ImportSourceDigest(item).rawValue == stored)
    }

    @Test
    func rawValueThenIgnoresTheDeviceIdentifierAndTheSpellingOfTheTitle() {
        // Given
        let onThisDevice = ImportedDate.mock(sourceIdentifier: "this-device", title: "Mary")
        let onAnotherDevice = ImportedDate.mock(sourceIdentifier: "other-device", title: " mary ")

        // When / Then
        #expect(ImportSourceDigest(onThisDevice) == ImportSourceDigest(onAnotherDevice))
    }
}
