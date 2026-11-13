//
//  ReminderIdentifierTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct ReminderIdentifierTests {
    @Test func rawValueThenKeepsTheShippedFormats() throws {
        // Given
        let eventID = try #require(UUID(uuidString: "11111111-2222-4333-8444-555555555555"))
        let partID = try #require(UUID(uuidString: "AAAAAAAA-BBBB-4CCC-8DDD-EEEEEEEEEEEE"))
        let occurrence = Date(timeIntervalSince1970: 1_800_000_000.9)

        // When
        let ordinary = ReminderIdentifier(
            eventID: eventID,
            subject: .rule(partID),
            occurrence: occurrence
        )
        let special = ReminderIdentifier(
            eventID: eventID,
            subject: .specialNode(partID),
            occurrence: occurrence
        )

        // Then
        #expect(
            ordinary.rawValue
                == "11111111-2222-4333-8444-555555555555.AAAAAAAA-BBBB-4CCC-8DDD-EEEEEEEEEEEE.1800000000"
        )
        #expect(
            special.rawValue
                == "11111111-2222-4333-8444-555555555555.special.AAAAAAAA-BBBB-4CCC-8DDD-EEEEEEEEEEEE.1800000000"
        )
    }
}
