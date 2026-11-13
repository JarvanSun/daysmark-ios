//
//  IntentTypeNamesTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import DaysMark

struct IntentTypeNamesTests {
    @Test func intentTypeNamesThenAreTheOnesShortcutsStored() {
        // Given / When / Then
        #expect(String(describing: FindImportantDatesIntent.self) == "FindImportantDatesIntent")
        #expect(
            String(describing: GetImportantDateDistanceIntent.self)
                == "GetImportantDateDistanceIntent"
        )
        #expect(String(describing: OpenImportantDateIntent.self) == "OpenImportantDateIntent")
        #expect(String(describing: CreateImportantDateIntent.self) == "CreateImportantDateIntent")
        #expect(String(describing: EditImportantDateIntent.self) == "EditImportantDateIntent")
    }

    @Test func entityAndQueryTypeNamesThenAreTheOnesShortcutsStored() {
        // Given / When / Then
        #expect(String(describing: ImportantDateEntity.self) == "ImportantDateEntity")
        #expect(String(describing: ImportantDateEntityQuery.self) == "ImportantDateEntityQuery")
        #expect(
            String(describing: ImportantDateCategoryEntity.self) == "ImportantDateCategoryEntity"
        )
        #expect(
            String(describing: ImportantDateCategoryQuery.self) == "ImportantDateCategoryQuery"
        )
    }

    @Test func enumAndShortcutsProviderTypeNamesThenAreTheOnesShortcutsStored() {
        // Given / When / Then
        #expect(String(describing: ImportantDateRepeatOption.self) == "ImportantDateRepeatOption")
        #expect(String(describing: ImportantDateAppShortcuts.self) == "ImportantDateAppShortcuts")
    }

    @Test func qualifiedTypeNamesThenKeepTheModuleTheMetadataNames() {
        // Given / When / Then
        #expect(
            String(reflecting: CreateImportantDateIntent.self)
                == "DaysMark.CreateImportantDateIntent"
        )
        #expect(String(reflecting: ImportantDateEntity.self) == "DaysMark.ImportantDateEntity")
        #expect(
            String(reflecting: ImportantDateEntityQuery.self)
                == "DaysMark.ImportantDateEntityQuery"
        )
    }
}
