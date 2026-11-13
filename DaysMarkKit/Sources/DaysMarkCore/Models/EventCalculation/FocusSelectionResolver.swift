//
//  FocusSelectionResolver.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation

public struct FocusSelectionResolver: Sendable {
    public init() {}

    public func selectedEventID(
        selections: [FocusSelection],
        revisions: [FocusSelectionRevision]
    ) -> UUID? {
        switch materialWinner(revisions) {
        case let winner?: winner.eventID
        case nil: selections.min { order(of: $0) < order(of: $1) }?.eventID
        }
    }

    func materialWinner(_ revisions: [FocusSelectionRevision]) -> FocusSelectionRevision? {
        let superseded = Set(
            revisions.compactMap(\.parentRevisionID) + revisions.flatMap(\.supersededRevisionIDs)
        )

        return
            revisions
            .filter { !superseded.contains($0.id) }
            .min { order(of: $0) < order(of: $1) }
    }

    private func order(of revision: FocusSelectionRevision) -> (TimeInterval, String) {
        (-revision.createdAt.timeIntervalSinceReferenceDate, revision.id.uuidString)
    }

    private func order(of selection: FocusSelection) -> (TimeInterval, String, String) {
        (
            -selection.updatedAt.timeIntervalSinceReferenceDate,
            selection.currentRevisionID?.uuidString ?? "",
            selection.recordID.uuidString
        )
    }
}
