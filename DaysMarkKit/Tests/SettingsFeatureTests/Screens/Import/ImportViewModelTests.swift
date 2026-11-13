//
//  ImportViewModelTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/10/07.
//

import DaysMarkCore
import Foundation
import TestSupport
import Testing

@testable import SettingsFeature

struct ImportViewModelTests {
    @Test func loadCandidatesThenSelectsWhatCanBeImportedAndSuggestsReminders() async {
        // Given
        let viewModel = makeViewModel(results: [.mockNew, .mockUnchanged, .mockConflict])
        viewModel.scan(.calendar, defaultReminderTime: .init(minuteOfDay: 540))

        // When
        await viewModel.loadCandidates()

        // Then
        let candidates = viewModel.review.candidates ?? []
        #expect(viewModel.activity == .reviewing)
        #expect(candidates.map(\.isSelected) == [true, false, true])
        #expect(candidates.map(\.resolution) == [.keepMine, .keepMine, .keepMine])
        #expect(
            candidates.map(\.reminder) == [
                .init(isEnabled: true, daysBefore: 0, time: .init(minuteOfDay: 540)), nil, nil,
            ]
        )
        #expect(viewModel.canImport)
    }

    @Test func loadCandidatesWhenNothingIsFoundThenSaysSo() async {
        // Given
        let viewModel = makeViewModel(results: [])
        viewModel.scan(.contacts, defaultReminderTime: .mockNine)

        // When
        await viewModel.loadCandidates()

        // Then
        #expect(viewModel.review == .nothingFound)
        #expect(!viewModel.canImport)
    }

    @Test func loadCandidatesWithoutARequestThenScansNothing() async {
        // Given
        let scanner = ImportScannerSpy()
        let viewModel = makeViewModel(scanner: scanner)

        // When
        await viewModel.loadCandidates()

        // Then
        #expect(scanner.scannedSources.isEmpty)
        #expect(viewModel.review == .notScanned)
    }

    @Test func loadCandidatesWhenScanningFailsThenShowsTheIssue() async {
        // Given
        let scanner = ImportScannerSpy(result: .failure(.permissionDenied))
        let viewModel = makeViewModel(scanner: scanner)
        viewModel.scan(.calendar, defaultReminderTime: .mockNine)

        // When
        await viewModel.loadCandidates()

        // Then
        #expect(viewModel.issue == .permissionDenied)
        #expect(viewModel.activity == .idle)
        #expect(viewModel.review == .notScanned)
    }

    @Test func loadCandidatesWhenCancelledThenStartsNoReview() async {
        // Given
        let viewModel = makeViewModel(results: [.mockNew])
        viewModel.scan(.calendar, defaultReminderTime: .mockNine)

        // When
        let task = Task { await viewModel.loadCandidates() }
        task.cancel()
        await task.value

        // Then
        #expect(viewModel.review == .notScanned)
        #expect(viewModel.issue == nil)
    }

    @Test func acknowledgeIssueThenClearsTheIssue() async {
        // Given
        let viewModel = makeViewModel(scanner: ImportScannerSpy(result: .failure(.storeFailure)))
        viewModel.scan(.calendar, defaultReminderTime: .mockNine)
        await viewModel.loadCandidates()

        // When
        viewModel.acknowledgeIssue()

        // Then
        #expect(viewModel.issue == nil)
    }

    @Test func setSelectionThenDecidesWhatIsImported() async {
        // Given
        let viewModel = await makeReviewingViewModel(results: [.mockNew])

        // When
        viewModel.setSelection(false, for: ImportResult.mockNew.id)

        // Then
        #expect(viewModel.review.candidates?.map(\.isSelected) == [false])
        #expect(!viewModel.canImport)
    }

    @Test func applySelectionThenPassesTheChosenResultsResolutionsAndReminders() async {
        // Given
        let applier = ImportApplierSpy()
        let viewModel = await makeReviewingViewModel(
            results: [.mockNew, .mockConflict, .mockChanged],
            applier: applier
        )
        viewModel.setSelection(false, for: ImportResult.mockChanged.id)
        viewModel.resolve(ImportResult.mockConflict.id, with: .importSource)
        viewModel.setReminder(
            .init(isEnabled: true, daysBefore: 2, time: .init(minuteOfDay: 600)),
            for: ImportResult.mockNew.id
        )
        viewModel.importSelection()

        // When
        await viewModel.applySelection()

        // Then
        #expect(
            applier.applications == [
                .init(
                    resultIDs: [ImportResult.mockNew.id, ImportResult.mockConflict.id],
                    resolutions: [
                        ImportResult.mockNew.id: .importSource,
                        ImportResult.mockConflict.id: .importSource,
                    ],
                    reminders: [
                        ImportResult.mockNew.id: .init(daysBefore: 2, hour: 10, minute: 0)
                    ]
                )
            ]
        )
        #expect(viewModel.activity == .imported)
        #expect(viewModel.review == .notScanned)
    }

    @Test func applySelectionWhenTheReminderIsSwitchedOffThenAddsNoReminder() async {
        // Given
        let applier = ImportApplierSpy()
        let viewModel = await makeReviewingViewModel(results: [.mockNew], applier: applier)
        viewModel.setReminder(
            .init(isEnabled: false, daysBefore: 0, time: .mockNine),
            for: ImportResult.mockNew.id
        )
        viewModel.importSelection()

        // When
        await viewModel.applySelection()

        // Then
        #expect(applier.applications.map(\.reminders) == [[:]])
    }

    @Test func applySelectionWhenApplyingFailsThenKeepsTheReview() async {
        // Given
        let applier = ImportApplierSpy(error: .localStoreUnavailable)
        let viewModel = await makeReviewingViewModel(results: [.mockNew], applier: applier)
        viewModel.importSelection()

        // When
        await viewModel.applySelection()

        // Then
        #expect(viewModel.issue == .storageUnavailable)
        #expect(viewModel.activity == .reviewing)
        #expect(viewModel.review.candidates?.count == 1)
    }

    @Test func applySelectionWithoutARequestThenAppliesNothing() async {
        // Given
        let applier = ImportApplierSpy()
        let viewModel = await makeReviewingViewModel(results: [.mockNew], applier: applier)

        // When
        await viewModel.applySelection()

        // Then
        #expect(applier.applications.isEmpty)
    }

    @Test func acknowledgeImportThenReturnsToTheStart() async {
        // Given
        let viewModel = await makeReviewingViewModel(results: [.mockNew])
        viewModel.importSelection()
        await viewModel.applySelection()

        // When
        viewModel.acknowledgeImport()

        // Then
        #expect(viewModel.activity == .idle)
    }

    @Test func isScanningWhenNotScanningThenIsFalse() {
        #expect(!makeViewModel().isScanning)
    }
}

private extension ImportViewModelTests {
    func makeViewModel(
        results: [ImportResult] = [],
        applier: ImportApplierSpy = .init()
    ) -> ImportViewModel {
        makeViewModel(scanner: .init(result: .success(results)), applier: applier)
    }

    func makeViewModel(
        scanner: ImportScannerSpy,
        applier: ImportApplierSpy = .init()
    ) -> ImportViewModel {
        ImportViewModel(scanner: scanner, applier: applier)
    }

    func makeReviewingViewModel(
        results: [ImportResult],
        applier: ImportApplierSpy = .init()
    ) async -> ImportViewModel {
        let viewModel = makeViewModel(results: results, applier: applier)
        viewModel.scan(.calendar, defaultReminderTime: .mockNine)
        await viewModel.loadCandidates()

        return viewModel
    }
}
