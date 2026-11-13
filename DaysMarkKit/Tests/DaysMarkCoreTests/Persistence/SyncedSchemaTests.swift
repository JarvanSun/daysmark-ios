//
//  SyncedSchemaTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct SyncedSchemaTests {
    @Test
    func modelsThenKeepLocalSourceRecordsOutOfTheSyncedSchema() {
        let syncedNames = Set(Schema.mockCurrent.entities.map(\.name))
        let localNames = Set(Schema.mockLocalSources.entities.map(\.name))
        #expect(syncedNames.contains("LocalSourceReference") == false)
        #expect(syncedNames.contains("LocalSourceCleanupRequest") == false)
        #expect(localNames == Set(["LocalSourceReference", "LocalSourceCleanupRequest"]))
    }

    @Test
    func modelsThenSatisfyTheCloudKitConstraints() {
        // Given
        let entities = Schema.mockCurrent.entities

        // When
        let unsyncableAttributes = entities.flatMap { entity in
            entity.attributes
                .filter { $0.isUnique || !($0.isOptional || $0.defaultValue != nil) }
                .map { "\(entity.name).\($0.name)" }
        }
        let unsyncableRelationships = entities.flatMap { entity in
            entity.relationships
                .filter { !$0.isOptional || $0.inverseName == nil || $0.deleteRule == .deny }
                .map { "\(entity.name).\($0.name)" }
        }

        // Then
        #expect(unsyncableAttributes.isEmpty)
        #expect(unsyncableRelationships.isEmpty)
        #expect(entities.flatMap(\.uniquenessConstraints).isEmpty)
    }

    @Test
    func modelsThenHoldFocusRecordsWithoutRelationships() {
        let names = Set(Schema.mockCurrent.entities.map(\.name))
        #expect(names.contains("FocusSelection"))
        #expect(names.contains("FocusSelectionRevision"))
        #expect(
            Schema.mockCurrent.entities.first { $0.name == "FocusSelection" }?.relationships
                .isEmpty == true
        )
        #expect(
            Schema.mockCurrent.entities.first { $0.name == "FocusSelectionRevision" }?
                .relationships.isEmpty == true
        )
    }
}
