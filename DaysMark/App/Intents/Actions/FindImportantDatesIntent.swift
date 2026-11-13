//
//  FindImportantDatesIntent.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore

struct FindImportantDatesIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.find.title"
    static let description = IntentDescription("intent.find.description")

    @Parameter(title: "intent.find.parameter.category") var category: ImportantDateCategoryEntity?
    @Parameter(title: "intent.find.parameter.limit", default: 3, inclusiveRange: (1, 3)) var limit:
        Int

    static var parameterSummary: some ParameterSummary {
        Summary("intent.find.summary \(\.$limit)") { \.$category }
    }

    @Dependency private var lookup: EventLookup

    func perform() async throws -> some IntentResult & ReturnsValue<[ImportantDateEntity]>
        & ProvidesDialog
    {
        let matches = await lookup.nearestEvents(limit: limit, in: category?.id)
        let entities = matches.map(ImportantDateEntity.init)
        let dialog: IntentDialog =
            entities.isEmpty
            ? "intent.find.dialog.none"
            : "intent.find.dialog.found \(entities.count)"

        return .result(value: entities, dialog: dialog)
    }
}
