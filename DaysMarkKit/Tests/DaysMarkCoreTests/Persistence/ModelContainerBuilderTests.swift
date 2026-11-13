//
//  ModelContainerBuilderTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/07/31.
//

import Foundation
import SwiftData
import TestSupport
import Testing

@testable import DaysMarkCore

struct ModelContainerBuilderTests {
    @Test func storeURLThenLivesInTheAppGroupContainer() throws {
        // Given
        let group = try #require(
            FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.example.daysmark"
            ),
            "Cannot access the App Group: check the identifier and the entitlement"
        )

        // When
        let url = try #require(ModelContainerBuilder(role: .app, storage: .appGroup).storeURL)

        // Then
        #expect(url.lastPathComponent == "CountdownDays.store")
        #expect(url.deletingLastPathComponent().path() == group.path())
    }

    @Test(arguments: [StoreRole.app, .widget])
    func makeContainerWhenInMemoryThenIsNotPersistedAndHasNoCloudKit(role: StoreRole) throws {
        // Given / When
        let container = try ModelContainerBuilder(role: role, storage: .inMemory).makeContainer()

        // Then
        #expect(container.configurations.first?.name == "CountdownDaysInMemory")
        #expect(container.configurations.first?.isStoredInMemoryOnly == true)
        #expect(container.configurations.first?.cloudKitContainerIdentifier == nil)
    }

    @Test func configurationWhenAppThenSavesToThePrivateCloudKitDatabase() {
        // Given / When
        let configuration = ModelContainerBuilder(role: .app, storage: .appGroup)
            .configuration(at: storeURL)

        // Then
        #expect(configuration.name == "CountdownDays")
        #expect(configuration.allowsSave)
        #expect(configuration.cloudKitContainerIdentifier == "iCloud.com.example.daysmark")
    }

    @Test func configurationWhenWidgetThenCannotSaveAndHasNoCloudKit() {
        // Given / When
        let configuration = ModelContainerBuilder(role: .widget, storage: .appGroup)
            .configuration(at: storeURL)

        // Then
        #expect(configuration.name == "CountdownDays")
        #expect(!configuration.allowsSave)
        #expect(configuration.cloudKitContainerIdentifier == nil)
    }

    @Test func makeLocalSourceContainerThenIsPrivateToTheDevice() throws {
        // Given / When
        let container = try #require(
            ModelContainerBuilder(role: .app, storage: .inMemory).makeLocalSourceContainer()
        )

        // Then
        #expect(container.configurations.first?.name == "CountdownDaysLocalSources")
        #expect(container.configurations.first?.cloudKitContainerIdentifier == nil)
    }

    @Test func makeLocalSourceContainerWhenTheStoreCannotOpenThenReturnsNil() {
        // Given
        let builder = ModelContainerBuilder(role: .app, storage: .inMemory)

        // When
        let container = builder.makeLocalSourceContainer { throw MockError() }

        // Then
        #expect(container == nil)
    }

    @Test
    func theWidgetReadPathPicksTheSameHeroAsTheApp() throws {
        let container = ModelContainer.mockInMemory()
        let writing = ModelContext(container)
        writing.insert(CountdownEvent.mock(title: "far", year: 2030, month: 9, day: 20))
        let berlin = try #require(TimeZone(identifier: "Europe/Berlin"))
        let focused = CountdownEvent.mock(
            title: "pinned",
            year: 2030,
            month: 12,
            day: 1,
            hour: 10,
            minute: 30,
            timeZone: berlin,
            timeSemantics: .fixedInstant
        )
        writing.insert(focused)
        let selection = FocusSelection.mock(eventID: focused.id)
        writing.insert(selection)
        try writing.save()

        let reading = ModelContext(container)
        let events = try reading.fetch(FetchDescriptor<CountdownEvent>())

        let now = try #require(
            Calendar(identifier: .gregorian).date(
                from: DateComponents(timeZone: berlin, year: 2026, month: 9, day: 3)
            )
        )
        let hero = try #require(
            EventSorter().focus(
                in: events,
                now: now,
                userTimeZone: berlin,
                focusedEventID: selection.eventID
            )
        )
        let expected = try #require(
            Calendar(identifier: .gregorian).date(
                from: DateComponents(
                    timeZone: berlin,
                    year: 2030,
                    month: 12,
                    day: 1,
                    hour: 10,
                    minute: 30
                )
            )
        )

        #expect(hero.event.title == "pinned")
        #expect(hero.event.timeSemantics == .fixedInstant)
        #expect(hero.event.utcOffsetSecondsAtCreation == 60 * 60)
        #expect(hero.resolvedOccurrenceStartDate == expected)
    }

    @Test
    func theWidgetReadPathHandlesAnEmptyStore() throws {
        let container = ModelContainer.mockInMemory()
        let events = try ModelContext(container).fetch(FetchDescriptor<CountdownEvent>())

        #expect(
            EventSorter().focus(
                in: events,
                now: .mockNow,
                userTimeZone: .mockUTC,
                focusedEventID: nil
            ) == nil
        )
    }

    private var storeURL: URL { URL(filePath: "/tmp/pinned.store") }
}
