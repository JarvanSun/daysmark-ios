//
//  StoreIdentifierTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import DaysMarkCore

struct StoreIdentifierTests {
    @Test func rawValuesThenKeepTheirShippedValues() {
        #expect(StoreIdentifier.appGroup.rawValue == "group.com.example.daysmark")
        #expect(StoreIdentifier.cloudKitContainer.rawValue == "iCloud.com.example.daysmark")
        #expect(StoreIdentifier.storeFile.rawValue == "CountdownDays.store")
        #expect(StoreIdentifier.configuration.rawValue == "CountdownDays")
        #expect(StoreIdentifier.inMemoryConfiguration.rawValue == "CountdownDaysInMemory")
        #expect(StoreIdentifier.localSources.rawValue == "CountdownDaysLocalSources")
    }
}
