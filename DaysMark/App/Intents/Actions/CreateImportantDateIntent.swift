//
//  CreateImportantDateIntent.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore
import Foundation

struct CreateImportantDateIntent: AppIntent {
    static let title: LocalizedStringResource = "intent.create.title"
    static let description = IntentDescription("intent.create.description")
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "intent.create.parameter.title") var eventTitle: String
    @Parameter(title: "intent.create.parameter.startDate") var startDate: Date
    @Parameter(title: "intent.create.parameter.includesTime", default: false) var includesTime: Bool
    @Parameter(title: "intent.create.parameter.endDate") var endDate: Date?
    @Parameter(title: "intent.create.parameter.category") var category: ImportantDateCategoryEntity?
    @Parameter(title: "intent.create.parameter.repeat", default: .never)
    var repeatOption: ImportantDateRepeatOption
    @Parameter(title: "intent.create.parameter.reminderDaysBefore") var reminderDaysBefore: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("intent.create.summary \(\.$eventTitle) \(\.$startDate)") {
            \.$includesTime
            \.$endDate
            \.$category
            \.$repeatOption
            \.$reminderDaysBefore
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
            actionName: .create,
            dialog: IntentDialog(stringLiteral: candidate.confirmation)
        )

        let entity = try await candidate.save(to: events, lookup: lookup)

        return .result(value: entity, dialog: "intent.create.dialog.created \(entity.title)")
    }

    private func candidate() async throws -> EventCandidate {
        var input = EventCreationInput(title: eventTitle, startDate: startDate)
        input.includesTime = includesTime
        input.endDate = endDate
        input.categoryID = category?.id
        input.repeatRule = repeatOption.repeatRule
        input.reminderDaysBefore = reminderDaysBefore

        do {
            return try await lookup.candidate(creating: input)
        } catch {
            throw error.intentError
        }
    }
}
