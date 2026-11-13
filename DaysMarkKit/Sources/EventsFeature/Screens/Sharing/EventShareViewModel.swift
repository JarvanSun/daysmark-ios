//
//  EventShareViewModel.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class EventShareViewModel {
    var includesCategory = false

    let time: CurrentTime
    private let eventID: CountdownEvent.ID
    private let events: EventRepository
    private let categories: CategoryRepository
    private let router: EventsRouting

    private(set) var data = ShareData()

    var content: EventShareContent? {
        data.content(of: eventID, includesCategory: includesCategory, at: time)
    }

    init(
        eventID: CountdownEvent.ID,
        events: EventRepository,
        categories: CategoryRepository,
        time: CurrentTime,
        router: EventsRouting
    ) {
        self.eventID = eventID
        self.events = events
        self.categories = categories
        self.time = time
        self.router = router
    }

    func observeStore() async {
        reload()

        for await _ in events.changes() {
            reload()
        }
    }

    func reload() {
        do {
            data = try ShareData(events: events.events(), categories: categories.categories())
        } catch {
            data = ShareData()
        }
    }

    func finish() {
        router.dismissSheet()
    }
}
