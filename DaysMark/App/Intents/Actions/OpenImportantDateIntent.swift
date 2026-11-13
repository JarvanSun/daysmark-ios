//
//  OpenImportantDateIntent.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents
import DaysMarkCore

struct OpenImportantDateIntent: OpenIntent {
    static let title: LocalizedStringResource = "intent.open.title"
    @Parameter(title: "intent.open.parameter.event") var target: ImportantDateEntity

    @Dependency private var requests: AppRequestInbox

    func perform() async throws -> some IntentResult {
        await requests.hold(.event(target.id))

        return .result()
    }
}
