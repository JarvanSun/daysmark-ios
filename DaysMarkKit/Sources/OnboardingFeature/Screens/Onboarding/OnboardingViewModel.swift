//
//  OnboardingViewModel.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DaysMarkCore
import Foundation
import Observation

@Observable
final class OnboardingViewModel {
    var birthday: Date

    private(set) var step: OnboardingStep = .welcome
    private(set) var selection: Set<OnboardingSeed> = [.newYear, .nextMonth, .monthEnd]
    private(set) var includesBirthday = false
    private(set) var isSaving = false
    private(set) var issue: OnboardingIssue?
    private(set) var saveRequest: SaveRequest?

    private let calendar: Calendar
    private let now: () -> Date
    private let completer: OnboardingCompleting
    private let router: OnboardingRouting

    init(
        birthday: Date,
        calendar: Calendar,
        now: @escaping () -> Date,
        completer: OnboardingCompleting,
        router: OnboardingRouting
    ) {
        self.birthday = birthday
        self.calendar = calendar
        self.now = now
        self.completer = completer
        self.router = router
    }

    var content: OnboardingContent {
        let counts = dayCounts()

        return OnboardingContent(
            headline: headline(counts),
            detail: detail(counts),
            horizon: horizonSeeds().compactMap { counts[$0] },
            candidates: candidates(counts),
            primaryAction: primaryAction,
            celebratesBirthday: step == .birthday && counts[.birthday]?.direction == .today
        )
    }

    private func dayCounts() -> [OnboardingSeed: DayCount] {
        let moment = now()
        let plan = OnboardingSeedPlan(calendar: calendar, now: moment)
        let sorter = EventSorter()
        let candidate = BirthdayCandidate(date: birthday)
        var counts: [OnboardingSeed: DayCount] = [:]

        for seed in [OnboardingSeed.birthday, .birthDate, .newYear, .nextMonth, .monthEnd] {
            let event = try? plan.event(for: seed, birthday: candidate)
            let counted = event.map {
                sorter.counted([$0], now: moment, userTimeZone: calendar.timeZone)
            }
            counts[seed] = counted?.first?.dayCount
        }

        return counts
    }

    private func headline(_ counts: [OnboardingSeed: DayCount]) -> OnboardingContent.Sentence? {
        switch step {
        case .welcome: sentence(for: .newYear, in: counts)
        case .birthday: sentence(for: .birthday, in: counts)
        case .quickEvents: nil
        }
    }

    private func detail(_ counts: [OnboardingSeed: DayCount]) -> OnboardingContent.Sentence? {
        switch step {
        case .birthday: sentence(for: .birthDate, in: counts)
        case .welcome, .quickEvents: nil
        }
    }

    private func sentence(
        for seed: OnboardingSeed,
        in counts: [OnboardingSeed: DayCount]
    ) -> OnboardingContent.Sentence? {
        counts[seed].map { OnboardingContent.Sentence(title: seed.title, count: $0) }
    }

    private func horizonSeeds() -> [OnboardingSeed] {
        switch step {
        case .welcome: [.newYear]
        case .birthday: [.newYear, .birthday, .birthDate]
        case .quickEvents: offeredSeeds.filter(selection.contains)
        }
    }

    private func candidates(_ counts: [OnboardingSeed: DayCount]) -> [OnboardingContent.Candidate] {
        offeredSeeds.enumerated().map { position, seed in
            OnboardingContent.Candidate(
                seed: seed,
                isSelected: selection.contains(seed),
                dayCount: counts[seed],
                showsSeparator: position > 0
            )
        }
    }

    func performPrimaryAction() {
        switch primaryAction {
        case .next: continueToNextStep()
        case .createSelected: createSelectedDates()
        case .startWithBasics: startWithBasics()
        }
    }

    func continueToNextStep() {
        switch step {
        case .welcome: step = .birthday
        case .birthday: keepBirthday()
        case .quickEvents: break
        }
    }

    private func keepBirthday() {
        includesBirthday = true
        selection.formUnion(birthdaySeeds)
        step = .quickEvents
    }

    func skipBirthday() {
        includesBirthday = false
        selection.subtract(birthdaySeeds)
        step = .quickEvents
    }

    func goBack() {
        switch step {
        case .welcome: break
        case .birthday: step = .welcome
        case .quickEvents: step = .birthday
        }
    }

    func toggle(_ seed: OnboardingSeed) {
        switch selection.contains(seed) {
        case true: selection.remove(seed)
        case false: selection.insert(seed)
        }
    }

    func createSelectedDates() {
        requestSave(of: selection)
    }

    func startWithBasics() {
        requestSave(of: [])
    }

    private func requestSave(of seeds: Set<OnboardingSeed>) {
        guard !isSaving else { return }

        saveRequest = SaveRequest(id: UUID(), seeds: seeds)
    }

    func save() async {
        guard let saveRequest else { return }

        isSaving = true
        let result = await complete(saveRequest)
        guard !Task.isCancelled else { return }

        self.saveRequest = nil
        isSaving = false
        finish(with: result)
    }

    private func complete(_ request: SaveRequest) async -> Result<Void, OnboardingError> {
        let chosenBirthday = includesBirthday ? BirthdayCandidate(date: birthday) : nil

        do {
            try await completer.complete(birthday: chosenBirthday, selected: request.seeds)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    private func finish(with result: Result<Void, OnboardingError>) {
        switch result {
        case .success: router.finishOnboarding()
        case .failure(let error): issue = OnboardingIssue(error)
        }
    }

    func acknowledgeIssue() {
        issue = nil
    }

    private var primaryAction: OnboardingPrimaryAction {
        switch (step, selection.isEmpty) {
        case (.welcome, _), (.birthday, _): .next
        case (.quickEvents, false): .createSelected
        case (.quickEvents, true): .startWithBasics
        }
    }

    private var birthdaySeeds: Set<OnboardingSeed> { [.birthday, .birthDate] }

    private var offeredSeeds: [OnboardingSeed] {
        switch includesBirthday {
        case true: [.birthday, .birthDate, .newYear, .nextMonth, .monthEnd]
        case false: [.newYear, .nextMonth, .monthEnd]
        }
    }
}

extension OnboardingViewModel {
    struct SaveRequest: Equatable {
        let id: UUID
        let seeds: Set<OnboardingSeed>
    }
}
