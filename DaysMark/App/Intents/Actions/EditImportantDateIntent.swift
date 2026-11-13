//
//  EditImportantDateIntent.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct EditImportantDateIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.edit.title"
    static let description = IntentDescription("intent.edit.description")
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(
        title: "intent.edit.parameter.event",
        requestDisambiguationDialog: "intent.edit.prompt.event"
    ) var event: ImportantDateEntity
    @Parameter(title: "intent.edit.parameter.newTitle") var newTitle: String?
    @Parameter(title: "intent.edit.parameter.newStartDate") var newStartDate: Date?
    @Parameter(title: "intent.edit.parameter.includesTime") var includesTime: Bool?
    @Parameter(title: "intent.edit.parameter.newCategory") var category:
        ImportantDateCategoryEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("intent.edit.summary \(\.$event)") {
            \.$newTitle
            \.$newStartDate
            \.$includesTime
            \.$category
        }
    }

    @Dependency private var lookup: EventLookup
    @Dependency private var events: EventRepository

    func perform() async throws -> some IntentResult & ReturnsValue<ImportantDateEntity>
        & ProvidesDialog
    {
        let candidate = try await candidate()

        try await requestConfirmation(
            conditions: [],
            actionName: .set,
            dialog: IntentDialog(stringLiteral: candidate.confirmation)
        )

        let updated = try await candidate.save(to: events, lookup: lookup)

        return .result(value: updated, dialog: "intent.edit.dialog.updated \(updated.title)")
    }

    private func candidate() async throws -> EventCandidate {
        let input = EventEditInput(
            title: newTitle,
            startDate: newStartDate,
            includesTime: includesTime,
            categoryID: category?.id
        )

        do {
            return try await lookup.candidate(editing: event.id, with: input)
        } catch {
            throw error.intentError
        }
    }
}
