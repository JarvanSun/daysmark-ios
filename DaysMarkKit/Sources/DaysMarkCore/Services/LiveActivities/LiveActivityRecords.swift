//
//  LiveActivityRecords.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct LiveActivityRecords {
    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func noteDismissal(of eventID: UUID, until terminalDate: Date) {
        defaults.set(terminalDate, forKey: key(for: eventID))
    }

    func clear(_ eventID: UUID) {
        defaults.removeObject(forKey: key(for: eventID))
    }

    func wasDismissed(_ eventID: UUID, now: Date) -> Bool {
        let stored = defaults.object(forKey: key(for: eventID)) as? Date

        guard let suppressedUntil = stored else { return false }

        guard suppressedUntil > now else {
            clear(eventID)
            return false
        }

        return true
    }

    private func key(for eventID: UUID) -> String {
        "liveActivity.dismissedUntil.\(eventID.uuidString)"
    }
}
