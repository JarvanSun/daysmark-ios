//
//  ImportViewModel.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class ImportViewModel {
    private let scanner: ImportScanning
    private let applier: ImportApplying

    private(set) var activity: ImportActivity = .idle
    private(set) var issue: ImportIssue?
    private(set) var scanRequest: ImportScanRequest?
    private(set) var applyRequest: UUID?

    private var results: [ImportResult] = []
    private var selection: Set<ImportResult.ID> = []
    private var resolutions: [ImportResult.ID: ImportResolution] = [:]
    private var reminders: [ImportResult.ID: ImportReminderSuggestion] = [:]

    var review: ImportReview {
        switch (activity, results.isEmpty) {
        case (.reviewing, true): .nothingFound
        case (_, false): .candidates(candidates())
        default: .notScanned
        }
    }

    var isScanning: Bool {
        if case .scanning = activity { true } else { false }
    }

    var canImport: Bool {
        !selection.isEmpty
    }

    init(scanner: ImportScanning, applier: ImportApplying) {
        self.scanner = scanner
        self.applier = applier
    }

    private func candidates() -> [ImportCandidate] {
        results.map { result in
            ImportCandidate(
                result: result,
                isSelected: selection.contains(result.id),
                resolution: resolutions[result.id] ?? .keepMine,
                reminder: reminders[result.id]
            )
        }
    }

    func scan(_ source: ImportScanSource, defaultReminderTime: TimeOfDay) {
        scanRequest = ImportScanRequest(
            id: UUID(),
            source: source,
            defaultReminderTime: defaultReminderTime
        )
    }

    func loadCandidates() async {
        guard let scanRequest else { return }

        clearReview()
        activity = .scanning(scanRequest.source)

        do {
            let found = try await scanner.scan(scanRequest.source)
            guard !Task.isCancelled else { return }

            startReview(of: found, defaultReminderTime: scanRequest.defaultReminderTime)
        } catch {
            issue = ImportIssue(error)
            activity = .idle
        }
    }

    private func startReview(of found: [ImportResult], defaultReminderTime: TimeOfDay) {
        let new = found.filter { $0.decision == .create }

        results = found
        selection = Set(found.filter(\.decision.isImportable).map(\.id))
        reminders = new.reduce(into: [:]) { reminders, result in
            reminders[result.id] = ImportReminderSuggestion(
                isEnabled: true,
                daysBefore: 0,
                time: defaultReminderTime
            )
        }
        activity = .reviewing
    }

    func setSelection(_ isSelected: Bool, for id: ImportResult.ID) {
        if isSelected {
            selection.insert(id)
        } else {
            selection.remove(id)
        }
    }

    func resolve(_ id: ImportResult.ID, with resolution: ImportResolution) {
        resolutions[id] = resolution
    }

    func setReminder(_ reminder: ImportReminderSuggestion, for id: ImportResult.ID) {
        reminders[id] = reminder
    }

    func importSelection() {
        applyRequest = UUID()
    }

    func applySelection() async {
        guard applyRequest != nil else { return }

        let chosen = results.filter { selection.contains($0.id) }
        let new = chosen.filter { $0.decision == .create }
        let conflicts = chosen.filter { $0.decision == .conflict }
        activity = .applying

        do {
            try await applier.apply(
                chosen,
                resolutions: Dictionary(
                    uniqueKeysWithValues: new.map { ($0.id, ImportResolution.importSource) }
                        + conflicts.map { ($0.id, resolutions[$0.id] ?? .keepMine) }
                ),
                reminders: new.reduce(into: [:]) { configurations, result in
                    configurations[result.id] = reminders[result.id]?.configuration
                }
            )
            guard !Task.isCancelled else { return }

            clearReview()
            activity = .imported
        } catch {
            issue = ImportIssue(error)
            activity = .reviewing
        }
    }

    func acknowledgeIssue() {
        issue = nil
    }

    func acknowledgeImport() {
        activity = .idle
    }

    private func clearReview() {
        results = []
        selection = []
        resolutions = [:]
        reminders = [:]
    }
}
