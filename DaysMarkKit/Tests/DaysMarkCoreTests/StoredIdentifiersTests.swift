//
//  StoredIdentifiersTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData
import Testing

@testable import DaysMarkCore

@MainActor
struct StoredIdentifiersTests {
    let eventID: UUID = UUID(uuidString: "11111111-2222-4333-8444-555555555555") ?? UUID()
    let shippedBuiltInCategoryKinds: [String] = ["important", "birthday", "anniversary"]
    let shippedBuiltInCategoryIDs: [String] = [
        "00000000-0000-4000-8000-000000000001", "00000000-0000-4000-8000-000000000002",
        "00000000-0000-4000-8000-000000000003",
    ]
    let shippedSchema: [String: [String]] = [
        "CountdownEvent": [
            "calendarSystemRaw", "category", "categoryID", "conflictFingerprint",
            "countsFromDayOne", "createdAt", "currentRevisionID", "deletedAt",
            "deletionRevisionID", "endDay", "endEra", "endHour", "endIsLeapMonth", "endMinute",
            "endMonth", "endUTCOffsetSecondsAtCreation", "endYear", "icon", "id",
            "isSpotlightHidden", "permanentDeletionRequestedAt", "rangeCalendarDaySpan",
            "rangeDurationSeconds", "recordID", "reminders", "repeatRule", "seedIdentifier",
            "snapshotDigest", "sourceKindRaw", "specialNodeNotificationHour",
            "specialNodeNotificationMinute", "specialReminderNodes", "storedRepeatInterval",
            "storedRepeatUnit", "targetDay", "targetEra", "targetHour",
            "targetIsLeapMonth", "targetMinute", "targetMonth", "targetYear",
            "timeSemanticsRaw", "timeZoneIdentifier", "title", "updatedAt",
            "utcOffsetSecondsAtCreation",
        ],
        "EventCategory": [
            "builtInKindRaw", "deletedAt", "events", "icon", "id", "name", "recordID",
            "sortOrder",
        ],
        "EventRevision": [
            "calendarSystemRaw", "categoryID", "conflictFingerprint", "conflictGroupID",
            "countsFromDayOne", "createdAt", "endDay", "endEra", "endHour", "endIsLeapMonth",
            "endMinute", "endMonth", "endUTCOffsetSecondsAtCreation", "endYear", "eventID",
            "icon", "id", "isDeletion", "isPermanentDeletionRequest", "isSpotlightHidden",
            "ordinaryReminderSnapshotData", "parentRevisionID", "rangeCalendarDaySpan",
            "rangeDurationSeconds", "recordID", "repeatInterval", "repeatRule", "repeatUnit",
            "restoredDeletionRevisionID", "snapshotDigest", "sourceKindRaw",
            "specialNodeNotificationHour", "specialNodeNotificationMinute",
            "specialNodeSnapshotData", "supersededRevisionIDs", "targetDay", "targetEra",
            "targetHour", "targetIsLeapMonth", "targetMinute", "targetMonth", "targetYear",
            "timeSemanticsRaw", "timeZoneIdentifier", "title", "utcOffsetSecondsAtCreation",
        ],
        "FocusSelection": [
            "currentRevisionID", "eventID", "id", "recordID", "updatedAt",
        ],
        "FocusSelectionRevision": [
            "conflictGroupID", "createdAt", "eventID", "id", "parentRevisionID", "recordID",
            "supersededRevisionIDs",
        ],
        "PermanentDeletionMarker": [
            "deletedAt", "eventID", "id", "seedIdentifier",
        ],
        "ReminderRule": [
            "daysBefore", "event", "eventID", "hour", "id", "kindRaw", "minute",
            "minutesBefore", "recordID",
        ],
        "SpecialReminderNode": [
            "event", "eventID", "id", "kindRaw", "recordID", "value",
        ],
        "LocalSourceCleanupRequest": [
            "eventID", "id", "requestedAt",
        ],
        "LocalSourceReference": [
            "eventID", "id", "rawIdentifier", "sourceKindRaw",
        ],
    ]

    @Test func modelNamesAndStoredPropertiesThenMatchTheShippedSchema() {
        // Given / When
        let stored = [Schema.mockCurrent, .mockLocalSources]
            .flatMap(\.entities)
            .reduce(into: [String: [String]]()) { names, entity in
                names[entity.name] =
                    (entity.attributes.map(\.name) + entity.relationships.map(\.name)).sorted()
            }

        // Then
        #expect(stored == shippedSchema)
    }

    @Test func liveActivityAttributesThenKeepTheirTypeNameAndCodableShape() throws {
        // Given
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let attributes = ImportantDateActivityAttributes(
            eventID: eventID,
            presentedTitle: "Launch",
            symbolName: "calendar",
            deepLink: try #require(URL(string: "daysmark://event/\(eventID.uuidString)"))
        )
        let state = ImportantDateActivityAttributes.ContentState(
            targetDate: Date(timeIntervalSince1970: 1_234.5),
            target: .end,
            isTerminal: true
        )

        // When
        let encodedAttributes = String(decoding: try encoder.encode(attributes), as: UTF8.self)
        let encodedState = String(decoding: try encoder.encode(state), as: UTF8.self)

        // Then
        #expect(
            String(reflecting: ImportantDateActivityAttributes.self)
                == "DaysMarkCore.ImportantDateActivityAttributes"
        )
        #expect(
            encodedAttributes
                == #"{"deepLink":"daysmark://event/11111111-2222-4333-8444-555555555555","eventID":"11111111-2222-4333-8444-555555555555","presentedTitle":"Launch","symbolName":"calendar"}"#
        )
        #expect(encodedState == #"{"isTerminal":true,"target":"end","targetTimestamp":1234.5}"#)
        #expect(ImportantDateActivityAttributes.Target.start.rawValue == "start")
        #expect(ImportantDateActivityAttributes.Target.point.rawValue == "point")
    }

    @Test func seedAndBuiltInIdentifiersThenKeepTheirShippedValues() {
        #expect(
            OnboardingSeed.allCases.map(\.rawValue) == [
                "onboarding.new-year.v1", "onboarding.next-month.v1", "onboarding.month-end.v1",
                "onboarding.my-birthday.v1", "onboarding.my-birth-date.v1",
                "onboarding.fallback.year-progress.v1", "onboarding.fallback.new-year.v1",
            ]
        )
        #expect(
            OnboardingSeed.allCases.map(\.eventID.uuidString)
                == (1...7).map {
                    "9A0B7C3D-1111-4B22-8C33-00000000000\($0)"
                }
        )
        #expect(BuiltInCategory.allCases.map(\.id.uuidString) == shippedBuiltInCategoryIDs)
        #expect(BuiltInCategory.allCases.map(\.rawValue) == shippedBuiltInCategoryKinds)
    }

    @Test func linksThenKeepTheirShippedForms() {
        #expect(
            AppRequest.event(eventID).url?.absoluteString
                == "daysmark://event/11111111-2222-4333-8444-555555555555"
        )
        #expect(
            AppRequest.category(eventID).url?.absoluteString
                == "daysmark://category/11111111-2222-4333-8444-555555555555"
        )
        #expect(AppRequest.collection(.all).url?.absoluteString == "daysmark://collection/all")
        #expect(
            AppRequest.collection(.birthdays).url?.absoluteString
                == "daysmark://collection/birthdays"
        )
        #expect(
            AppRequest.collection(.anniversaries).url?.absoluteString
                == "daysmark://collection/anniversaries"
        )
        #expect(AppRequest.widgets.url?.absoluteString == "daysmark://widgets")
    }
}
