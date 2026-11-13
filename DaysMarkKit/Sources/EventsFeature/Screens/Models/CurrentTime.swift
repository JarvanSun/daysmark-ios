//
//  CurrentTime.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DesignSystem
import Foundation
import Observation

@Observable
final class CurrentTime: MomentRefreshing {
    private(set) var now: Date
    private(set) var timeZone: TimeZone
    private(set) var locale: Locale

    init(now: Date = .now, timeZone: TimeZone = .current, locale: Locale = .current) {
        self.now = now
        self.timeZone = timeZone
        self.locale = locale
    }

    func refresh() {
        move(to: .now, timeZone: .current)
    }

    func move(to now: Date, timeZone: TimeZone) {
        self.now = now
        self.timeZone = timeZone
    }
}
