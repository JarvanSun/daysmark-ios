//
//  LandscapeMarker.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct LandscapeMarker: Hashable, Sendable {
    let days: Int
    let isPast: Bool

    public init(days: Int, isPast: Bool) {
        self.days = days
        self.isPast = isPast
    }

}
