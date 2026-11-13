//
//  ImportServiceTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

@MainActor
struct ImportServiceTests {
    @Test
    func applyWithoutRemindersThenWritesAndRefreshesOnceWithoutAskingForPermission() async throws {
        // Given
        let synced = ModelContainer.mockInMemory()
        let permission = NotificationPermissionRequesterSpy()
        let refresher = SystemSurfaceRefresherSpy()
        let service = ImportService.mock(
            in: synced,
            localSources: .mockLocalSources(),
            notificationPermission: permission,
            refresher: refresher
        )
        let results = try service.results(for: [.mockContactBirthday])

        // When
        try await service.apply(results, resolutions: [:], reminders: [:])
        await service.permissionRequest?.value

        // Then
        #expect(try synced.mainContext.fetch(FetchDescriptor<CountdownEvent>()).count == 1)
        #expect(permission.requestCount == 0)
        #expect(refresher.refreshCount == 1)
    }

    @Test
    func applyWithRemindersThenAsksForPermissionAndRefreshesAgain() async throws {
        // Given
        let permission = NotificationPermissionRequesterSpy()
        let refresher = SystemSurfaceRefresherSpy()
        let service = ImportService.mock(
            in: .mockInMemory(),
            localSources: .mockLocalSources(),
            notificationPermission: permission,
            refresher: refresher
        )
        let item = ImportedDate.mockContactBirthday
        let results = try service.results(for: [item])

        // When
        try await service.apply(
            results,
            resolutions: [:],
            reminders: [item.id: ImportReminderConfiguration(daysBefore: 0, hour: 9, minute: 0)]
        )
        await service.permissionRequest?.value

        // Then
        #expect(permission.requestCount == 1)
        #expect(refresher.refreshCount == 2)
    }

    @Test(arguments: [ImportScanSource.contacts, .calendar])
    func scanWithoutALocalSourceStoreThenThrowsLocalStoreUnavailable(
        source: ImportScanSource
    ) async {
        // Given
        let service = ImportService.mock(in: .mockInMemory(), localSources: nil)

        // When / Then
        await #expect(throws: ImportError.localStoreUnavailable) {
            try await service.scan(source)
        }
    }

    @Test
    func applyWhenTheStoreRejectsTheSaveThenThrowsStoreFailureAndRefreshesNothing() async throws {
        // Given
        let store = try ReadOnlyStore(seededWith: [])
        let localSources = ModelContainer.mockLocalSources()
        let refresher = SystemSurfaceRefresherSpy()
        let service = ImportService.mock(
            in: store.container,
            localSources: localSources,
            refresher: refresher
        )
        let results = try service.results(for: [.mockContactBirthday])

        // When / Then
        await #expect(throws: ImportError.storeFailure) {
            try await service.apply(results, resolutions: [:], reminders: [:])
        }
        #expect(refresher.refreshCount == 0)
        #expect(
            try localSources.mainContext.fetch(FetchDescriptor<LocalSourceReference>()).isEmpty
        )
    }
}
