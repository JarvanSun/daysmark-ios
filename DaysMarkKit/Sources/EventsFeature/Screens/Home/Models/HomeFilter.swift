//
//  HomeFilter.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import Foundation

struct HomeFilter: Equatable {
    var categoryID: EventCategory.ID?
    var searchText = ""

    var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isSearching: Bool {
        !query.isEmpty
    }

    func shows(_ event: CountdownEvent, categoryName: String?) -> Bool {
        guard isSearching else { return categoryID == nil || event.categoryID == categoryID }

        return event.title.localizedStandardContains(query)
            || categoryName?.localizedStandardContains(query) == true
    }
}
