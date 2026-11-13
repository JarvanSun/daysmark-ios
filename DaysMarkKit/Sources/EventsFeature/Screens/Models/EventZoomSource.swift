//
//  EventZoomSource.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

nonisolated struct EventZoomSource: Hashable {
    let eventID: CountdownEvent.ID
    let isFocus: Bool
}
