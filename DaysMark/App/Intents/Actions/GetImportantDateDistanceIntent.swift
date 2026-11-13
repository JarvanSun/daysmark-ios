//
//  GetImportantDateDistanceIntent.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct GetImportantDateDistanceIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.distance.title"

    @Parameter(
        title: "intent.distance.parameter.event",
        requestDisambiguationDialog: "intent.distance.prompt.event"
    ) var event: ImportantDateEntity

    static var parameterSummary: some ParameterSummary {
        Summary("intent.distance.summary \(\.$event)")
    }

    @Dependency private var lookup: EventLookup

    func perform() async throws -> some IntentResult & ReturnsValue<ImportantDateEntity>
        & ProvidesDialog
    {
        let text =
            await lookup.distancePhrase(for: event.id)
            ?? String(localized: "intent.distance.dialog.unavailable")

        return .result(value: event, dialog: IntentDialog(stringLiteral: text))
    }
}
