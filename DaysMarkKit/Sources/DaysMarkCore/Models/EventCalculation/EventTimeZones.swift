//
//  EventTimeZones.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct EventTimeZones {
    let event: TimeZone?
    let user: TimeZone

    func resolution(for semantics: EventTimeSemantics) -> TimeZone? {
        switch semantics {
        case .fixedInstant: event
        case .floatingAllDay, .floatingLocalTime: user
        }
    }
}
