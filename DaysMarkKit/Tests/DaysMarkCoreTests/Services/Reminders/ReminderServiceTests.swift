//
//  ReminderServiceTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/28.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct ReminderServiceTests {
    @Test func reconcileThenSchedulesTheRemindersOfVisibleEvents() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let scheduler = NotificationSchedulerSpy()
        let service = makeService(container: container, scheduler: scheduler)
        let event = CountdownEvent.mock(reminderDays: [0])
        container.mainContext.insert(event)
        try container.mainContext.save()

        // When
        await service.reconcile()

        // Then
        #expect(scheduler.added.map(\.title) == [event.title])
    }

    @Test func reconcileWhenAnEventIsDeletedThenSchedulesNothingForIt() async throws {
        // Given
        let container = ModelContainer.mockInMemory()
        let scheduler = NotificationSchedulerSpy()
        let service = makeService(container: container, scheduler: scheduler)
        let event = CountdownEvent.mock(reminderDays: [0])
        event.deletedAt = .mockNow
        container.mainContext.insert(event)
        try container.mainContext.save()

        // When
        await service.reconcile()

        // Then
        #expect(scheduler.added.isEmpty)
    }

    @Test func reconcileWhenAnEventWasDeletedInAnotherContextThenSchedulesNothingForIt()
        async throws
    {
        // Given
        let container = ModelContainer.mockInMemory()
        let scheduler = NotificationSchedulerSpy()
        let service = makeService(container: container, scheduler: scheduler)
        let event = CountdownEvent.mock(reminderDays: [0])
        container.mainContext.insert(event)
        try container.mainContext.save()
        let events = SwiftDataEventRepository.mock(in: container.mainContext.container)
        try events.delete(eventID: event.id)

        // When
        await service.reconcile()

        // Then
        #expect(scheduler.added.isEmpty)
    }

    @Test func reconcileWhenRequestedConcurrentlyThenRunsOnePassAtATime() async {
        // Given
        let scheduler = NotificationSchedulerSpy()
        let service = makeService(scheduler: scheduler)

        // When
        let passes = (0..<3).map { _ in Task { await service.reconcile() } }

        for pass in passes {
            await pass.value
        }

        // Then
        #expect(scheduler.passes == 3)
        #expect(scheduler.mostConcurrentPasses == 1)
    }

    @Test func reconcileWhenCancelledThenStopsAddingReminders() async {
        // Given
        let container = ModelContainer.mockInMemory()
        let scheduler = NotificationSchedulerSpy()
        let service = makeService(container: container, scheduler: scheduler)

        for index in 1...20 {
            container.mainContext.insert(
                CountdownEvent.mock(title: "Event \(index)", reminderDays: [0, 1, 2])
            )
        }

        // When
        let work = Task { await service.reconcile() }
        work.cancel()
        await work.value

        // Then
        #expect(scheduler.added.count < 60)
    }

    @Test func registerCategoriesThenRegistersThemWithTheScheduler() async {
        // Given
        let scheduler = NotificationSchedulerSpy()
        let service = makeService(scheduler: scheduler)

        // When
        await service.registerCategories()

        // Then
        #expect(scheduler.categoryRegistrations == 1)
    }

    @Test func currentPermissionThenReadsTheAuthorizer() async {
        // Given
        let service = makeService(authorizer: NotificationAuthorizerStub(permission: .authorized))

        // When / Then
        #expect(await service.currentPermission() == .authorized)
    }

    @Test(arguments: [true, false])
    func requestIfNeededWhenNotDeterminedThenAsksOnce(grants: Bool) async {
        // Given
        let authorizer = NotificationAuthorizerStub(permission: .notDetermined, grants: grants)
        let service = makeService(authorizer: authorizer)

        // When
        let permission = await service.requestIfNeeded()

        // Then
        #expect(permission == (grants ? .authorized : .denied))
        #expect(authorizer.requestCount == 1)
    }

    @Test(arguments: [NotificationPermission.authorized, .denied])
    func requestIfNeededWhenAlreadyDecidedThenDoesNotAsk(decided: NotificationPermission) async {
        // Given
        let authorizer = NotificationAuthorizerStub(permission: decided)
        let service = makeService(authorizer: authorizer)

        // When
        let permission = await service.requestIfNeeded()

        // Then
        #expect(permission == decided)
        #expect(authorizer.requestCount == 0)
    }

    @Test func requestIfNeededWhenTheRequestFailsThenStaysNotDetermined() async {
        // Given
        let authorizer = NotificationAuthorizerStub(permission: .notDetermined, error: MockError())
        let service = makeService(authorizer: authorizer)

        // When
        let permission = await service.requestIfNeeded()

        // Then
        #expect(permission == .notDetermined)
    }

    private func makeService(
        container: ModelContainer = .mockInMemory(),
        scheduler: NotificationSchedulerSpy = NotificationSchedulerSpy(),
        authorizer: NotificationAuthorizerStub = NotificationAuthorizerStub(permission: .authorized)
    ) -> ReminderService {
        ReminderService(
            container: container,
            scheduler: scheduler,
            authorizer: authorizer,
            now: { .mockNow },
            timeZone: { .mockUTC }
        )
    }
}
