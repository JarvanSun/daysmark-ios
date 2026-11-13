//
//  NotificationsViewModelTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/10/07.
//

import DaysMarkCore
import TestSupport
import Testing

@testable import SettingsFeature

struct NotificationsViewModelTests {
    @Test func refreshThenReadsTheCurrentPermission() async {
        // Given
        let viewModel = makeViewModel(requester: .init(current: .authorized))

        // When
        await viewModel.refresh()

        // Then
        #expect(viewModel.permission == .authorized)
    }

    @Test func refreshWhenCancelledThenKeepsThePermission() async {
        // Given
        let viewModel = makeViewModel(requester: .init(current: .denied))

        // When
        let task = Task { await viewModel.refresh() }
        task.cancel()
        await task.value

        // Then
        #expect(viewModel.permission == .notDetermined)
    }

    @Test func enableNotificationsThenStartsAPermissionRequest() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.enableNotifications()

        // Then
        #expect(viewModel.activity == .requestingPermission)
        #expect(viewModel.permissionRequest != nil)
    }

    @Test(arguments: [NotificationPermission.authorized, .denied])
    func requestPermissionThenShowsWhatTheUserDecided(granted: NotificationPermission) async {
        // Given
        let viewModel = makeViewModel(requester: .init(granted: granted))
        viewModel.enableNotifications()

        // When
        await viewModel.requestPermission()

        // Then
        #expect(viewModel.permission == granted)
    }

    @Test func requestPermissionThenReturnsToIdle() async {
        // Given
        let viewModel = makeViewModel()
        viewModel.enableNotifications()

        // When
        await viewModel.requestPermission()

        // Then
        #expect(viewModel.activity == .idle)
    }

    @Test func enableNotificationsTwiceThenAsksOnce() async {
        // Given
        let requester = NotificationPermissionRequesterSpy()
        let viewModel = makeViewModel(requester: requester)

        // When
        viewModel.enableNotifications()
        let firstRequest = viewModel.permissionRequest
        viewModel.enableNotifications()
        await viewModel.requestPermission()

        // Then
        #expect(viewModel.permissionRequest == firstRequest)
        #expect(requester.requestCount == 1)
    }

    @Test func requestPermissionWithoutARequestThenAsksNothing() async {
        // Given
        let requester = NotificationPermissionRequesterSpy()
        let viewModel = makeViewModel(requester: requester)

        // When
        await viewModel.requestPermission()

        // Then
        #expect(requester.requestCount == 0)
    }

    private func makeViewModel(
        requester: NotificationPermissionRequesterSpy = .init()
    ) -> NotificationsViewModel {
        .init(permissionRequester: requester)
    }
}
