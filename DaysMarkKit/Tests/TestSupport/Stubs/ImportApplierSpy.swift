//
//  ImportApplierSpy.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

public final class ImportApplierSpy: ImportApplying {
    public struct Application: Equatable {
        public let resultIDs: [ImportResult.ID]
        public let resolutions: [ImportResult.ID: ImportResolution]
        public let reminders: [ImportResult.ID: ImportReminderConfiguration]

        public init(
            resultIDs: [ImportResult.ID],
            resolutions: [ImportResult.ID: ImportResolution],
            reminders: [ImportResult.ID: ImportReminderConfiguration]
        ) {
            self.resultIDs = resultIDs
            self.resolutions = resolutions
            self.reminders = reminders
        }
    }

    public private(set) var applications: [Application] = []

    private let error: ImportError?

    public init(error: ImportError? = nil) {
        self.error = error
    }

    public func apply(
        _ results: [ImportResult],
        resolutions: [String: ImportResolution],
        reminders: [String: ImportReminderConfiguration]
    ) async throws(ImportError) {
        applications.append(
            Application(
                resultIDs: results.map(\.id),
                resolutions: resolutions,
                reminders: reminders
            )
        )

        if let error {
            throw error
        }
    }
}
