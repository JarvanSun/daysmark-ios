//
//  ModelContextExtensions.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

extension ModelContext {
    func event(withID id: UUID) throws -> CountdownEvent {
        var descriptor = FetchDescriptor<CountdownEvent>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1

        guard let event = try fetch(descriptor).first else { throw EventError.eventUnavailable }

        return event
    }

    func storedCategory(_ category: BuiltInCategory) throws -> EventCategory? {
        try fetch(FetchDescriptor<EventCategory>()).first { $0.id == category.id }
    }
}
