//
//  UUIDExtensionsTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct UUIDExtensionsTests {
    @Test(arguments: [
        (UInt32(0x0000_0000), UInt8(0x01), "00000000-0000-4000-8000-000000000001"),
        (0xF0C0_0000, 0x10, "F0C00000-0000-4000-8000-000000000010"),
        (0x88A3_0000, 0x04, "88A30000-0000-4000-8000-000000000004"),
    ])
    func initFixedGroupThenWritesAVersionFourIdentifier(
        group: UInt32,
        number: UInt8,
        expected: String
    ) {
        #expect(UUID(fixedGroup: group, number: number).uuidString == expected)
    }
}
