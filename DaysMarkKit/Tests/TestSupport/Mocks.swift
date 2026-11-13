//
//  Mocks.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

extension Calendar {
    nonisolated public static var mockGregorianUTC: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt

        return calendar
    }
}

nonisolated public struct MockError: Error {
    public init() {}
}
