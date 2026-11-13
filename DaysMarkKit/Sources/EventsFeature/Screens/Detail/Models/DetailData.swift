//
//  DetailData.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

struct DetailData {
    var events: [CountdownEvent] = []
    var pinnedEventID: CountdownEvent.ID?
    var conflictVersions: [EventConflictVersion] = []

    func content(
        of eventID: CountdownEvent.ID,
        unit: EventDetailUnit,
        at time: CurrentTime
    ) -> DetailContent {
        let shown = events.filter { $0.id == eventID && $0.deletedAt == nil }
        let counted = EventSorter()
            .counted(shown, now: time.now, userTimeZone: time.timeZone)
            .first

        return DetailContent(
            event: counted.map { EventItem($0, at: time) },
            pinAction: PinAction(for: eventID, pinnedEventID: pinnedEventID),
            unit: unit,
            conflictVersions: conflictVersions,
            nextChange: counted.flatMap {
                EventBrowseRefreshPlanner()
                    .nextBoundary(after: time.now, items: [$0], userTimeZone: time.timeZone)
            }
        )
    }
}
