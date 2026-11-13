//
//  OnboardingViewModelTests.swift
//  OnboardingFeatureTests
//
//  Created by Jiawen Sun on 2026/10/07.
//

import DaysMarkCore
import Foundation
import TestSupport
import Testing

@testable import OnboardingFeature

struct OnboardingViewModelTests {
    @Test(arguments: [
        (Date.mock(year: 2026, month: 1, day: 1), 365),
        (.mock(year: 2026, month: 12, day: 31, hour: 23), 1),
        (.mock(year: 2028, month: 1, day: 1), 366),
    ])
    func contentOnWelcomeThenCountsToTheNextFirstOfJanuary(now: Date, days: Int) {
        // Given
        let viewModel = makeViewModel(now: now)

        // When
        let headline = viewModel.content.headline

        // Then
        #expect(headline?.title.key == "onboarding.seed.newYear")
        #expect(headline?.count.days == days)
        #expect(viewModel.content.detail == nil)
    }

    @Test func contentOnBirthdayThenLooksAheadToTheBirthdayAndBackToTheBirthDate() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.continueToNextStep()

        // Then
        #expect(viewModel.content.headline?.count.direction == .upcoming)
        #expect(viewModel.content.detail?.count.direction == .past)
    }

    @Test func contentWhenBirthdayIsTodayThenCelebratesOnTheBirthdayStep() {
        // Given
        let viewModel = makeViewModel()
        viewModel.continueToNextStep()

        // When
        viewModel.birthday = .mock(year: 2000, month: 9, day: 5)

        // Then
        #expect(viewModel.content.celebratesBirthday)
    }

    @Test func contentWhenNotOnTheBirthdayStepThenDoesNotCelebrate() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.birthday = .mock(year: 2000, month: 9, day: 5)

        // Then
        #expect(!viewModel.content.celebratesBirthday)
    }

    @Test func contentHorizonThenGrowsWithTheSteps() {
        // Given
        let viewModel = makeViewModel()
        var counts = [viewModel.content.horizon.count]

        // When
        viewModel.continueToNextStep()
        counts.append(viewModel.content.horizon.count)
        viewModel.continueToNextStep()
        counts.append(viewModel.content.horizon.count)
        viewModel.toggle(.newYear)
        counts.append(viewModel.content.horizon.count)

        // Then
        #expect(counts == [1, 3, 5, 4])
    }

    @Test func continueToNextStepFromBirthdayThenOffersAndSelectsBirthdayDates() {
        // Given
        let viewModel = makeViewModel()
        viewModel.continueToNextStep()

        // When
        viewModel.continueToNextStep()

        // Then
        #expect(viewModel.step == .quickEvents)
        #expect(
            viewModel.content.candidates.map(\.seed) == [
                .birthday, .birthDate, .newYear, .nextMonth, .monthEnd,
            ]
        )
        #expect(
            viewModel.content.candidates.map(\.showsSeparator) == [false, true, true, true, true]
        )
        #expect(viewModel.content.candidates.allSatisfy { $0.isSelected })
    }

    @Test func skipBirthdayThenOffersOnlyGeneralDatesAndSavesWithoutBirthday() async {
        // Given
        let completer = OnboardingCompleterSpy()
        let viewModel = makeViewModel(completer: completer)
        viewModel.continueToNextStep()

        // When
        viewModel.skipBirthday()
        viewModel.createSelectedDates()
        await viewModel.save()

        // Then
        #expect(viewModel.content.candidates.map(\.seed) == [.newYear, .nextMonth, .monthEnd])
        #expect(
            completer.completions == [
                OnboardingCompleterSpy.Completion(
                    birthday: nil,
                    seeds: [.newYear, .nextMonth, .monthEnd]
                )
            ]
        )
    }

    @Test func goBackThenReturnsOneStepAndKeepsBirthdayDatesOnTheWayForward() {
        // Given
        let viewModel = makeViewModel()
        viewModel.continueToNextStep()
        viewModel.continueToNextStep()
        viewModel.toggle(.birthday)

        // When
        viewModel.goBack()
        let stepAfterGoingBack = viewModel.step
        viewModel.continueToNextStep()

        // Then
        #expect(stepAfterGoingBack == .birthday)
        #expect(viewModel.selection.isSuperset(of: [.birthday, .birthDate]))
    }

    @Test func goBackFromBirthdayThenShowsWelcome() {
        // Given
        let viewModel = makeViewModel()
        viewModel.continueToNextStep()

        // When
        viewModel.goBack()

        // Then
        #expect(viewModel.step == .welcome)
    }

    @Test func toggleThenFlipsTheSelectionOfThatSeed() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.toggle(.newYear)
        let selectionAfterFirstToggle = viewModel.selection
        viewModel.toggle(.newYear)

        // Then
        #expect(selectionAfterFirstToggle == [.nextMonth, .monthEnd])
        #expect(viewModel.selection == [.newYear, .nextMonth, .monthEnd])
    }

    @Test(arguments: [
        (0, false, OnboardingPrimaryAction.next),
        (1, false, .next),
        (2, false, .createSelected),
        (2, true, .startWithBasics),
    ])
    func primaryActionThenFollowsTheStepAndTheSelection(
        stepsTaken: Int,
        clearsSelection: Bool,
        expected: OnboardingPrimaryAction
    ) {
        // Given
        let viewModel = makeViewModel()

        // When
        advance(viewModel, by: stepsTaken)
        clearSelection(of: viewModel, when: clearsSelection)

        // Then
        #expect(viewModel.content.primaryAction == expected)
    }

    @Test func performPrimaryActionThenWalksThroughTheStepsAndSavesTheSelection() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.performPrimaryAction()
        viewModel.performPrimaryAction()
        viewModel.performPrimaryAction()

        // Then
        #expect(viewModel.step == .quickEvents)
        #expect(
            viewModel.saveRequest?.seeds == [
                .birthday, .birthDate, .newYear, .nextMonth, .monthEnd,
            ]
        )
    }

    @Test func saveWhenCompleterSucceedsThenFinishesOnboarding() async {
        // Given
        let completer = OnboardingCompleterSpy()
        let router = OnboardingRouterSpy()
        let viewModel = makeViewModel(completer: completer, router: router)
        advance(viewModel, by: 2)
        viewModel.createSelectedDates()

        // When
        await viewModel.save()

        // Then
        #expect(
            completer.completions == [
                OnboardingCompleterSpy.Completion(
                    birthday: BirthdayCandidate(date: viewModel.birthday),
                    seeds: [.birthday, .birthDate, .newYear, .nextMonth, .monthEnd]
                )
            ]
        )
        #expect(!viewModel.isSaving)
        #expect(viewModel.issue == nil)
        #expect(viewModel.saveRequest == nil)
        #expect(router.finishCount == 1)
    }

    @Test func saveWhenCompleterFailsThenShowsTheIssueAndStaysInTheFlow() async {
        // Given
        let router = OnboardingRouterSpy()
        let viewModel = makeViewModel(
            completer: OnboardingCompleterSpy(error: .invalidBirthday),
            router: router
        )
        viewModel.createSelectedDates()

        // When
        await viewModel.save()

        // Then
        #expect(viewModel.issue == .invalidBirthday)
        #expect(!viewModel.isSaving)
        #expect(router.finishCount == 0)
    }

    @Test func saveWithoutARequestThenDoesNothing() async {
        // Given
        let completer = OnboardingCompleterSpy()
        let viewModel = makeViewModel(completer: completer)

        // When
        await viewModel.save()

        // Then
        #expect(completer.completions.isEmpty)
        #expect(!viewModel.isSaving)
    }

    @Test func saveWhenCancelledThenNeitherFinishesNorShowsAnIssue() async {
        // Given
        let router = OnboardingRouterSpy()
        let viewModel = makeViewModel(router: router)
        viewModel.createSelectedDates()

        // When
        let task = Task { await viewModel.save() }
        task.cancel()
        await task.value

        // Then
        #expect(router.finishCount == 0)
        #expect(viewModel.issue == nil)
    }

    @Test func startWithBasicsThenSavesNoSeeds() async {
        // Given
        let completer = OnboardingCompleterSpy()
        let viewModel = makeViewModel(completer: completer)

        // When
        viewModel.startWithBasics()
        await viewModel.save()

        // Then
        #expect(
            completer.completions == [OnboardingCompleterSpy.Completion(birthday: nil, seeds: [])]
        )
    }

    @Test func createSelectedDatesAfterAFailureThenSavesTheSelectionAgain() async {
        // Given
        let completer = OnboardingCompleterSpy(error: .storeFailure)
        let viewModel = makeViewModel(completer: completer)
        viewModel.startWithBasics()
        await viewModel.save()

        // When
        viewModel.createSelectedDates()
        await viewModel.save()

        // Then
        #expect(completer.completions.map(\.seeds) == [[], [.newYear, .nextMonth, .monthEnd]])
        #expect(viewModel.issue == .unknown)
    }

    @Test func acknowledgeIssueThenClearsTheIssue() async {
        // Given
        let viewModel = makeViewModel(completer: OnboardingCompleterSpy(error: .storeFailure))
        viewModel.createSelectedDates()
        await viewModel.save()

        // When
        viewModel.acknowledgeIssue()

        // Then
        #expect(viewModel.issue == nil)
    }
}

private extension OnboardingViewModelTests {
    func makeViewModel(
        now: Date = .mockNow,
        completer: OnboardingCompleterSpy = OnboardingCompleterSpy(),
        router: OnboardingRouterSpy = OnboardingRouterSpy()
    ) -> OnboardingViewModel {
        OnboardingViewModel(
            birthday: .mock(year: 2000, month: 1, day: 1, hour: 0),
            calendar: .mockGregorianUTC,
            now: { now },
            completer: completer,
            router: router
        )
    }

    func advance(_ viewModel: OnboardingViewModel, by steps: Int) {
        for _ in 0..<steps {
            viewModel.continueToNextStep()
        }
    }

    func clearSelection(of viewModel: OnboardingViewModel, when isCleared: Bool) {
        guard isCleared else { return }

        for candidate in viewModel.content.candidates {
            viewModel.toggle(candidate.seed)
        }
    }
}
