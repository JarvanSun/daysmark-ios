//
//  UUIDExtensions.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension UUID {
    init(fixedGroup group: UInt32, number: UInt8) {
        self.init(
            uuid: (
                UInt8(truncatingIfNeeded: group >> 24),
                UInt8(truncatingIfNeeded: group >> 16),
                UInt8(truncatingIfNeeded: group >> 8),
                UInt8(truncatingIfNeeded: group),
                0x00, 0x00,
                0x40, 0x00,
                0x80, 0x00,
                0x00, 0x00, 0x00, 0x00, 0x00, number
            )
        )
    }
}
