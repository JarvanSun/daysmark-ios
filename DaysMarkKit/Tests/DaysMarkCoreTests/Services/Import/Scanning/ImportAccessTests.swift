//
//  ImportAccessTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Contacts
import EventKit
import Testing

@testable import DaysMarkCore

struct ImportAccessTests {
    @Test(arguments: [
        (CNAuthorizationStatus.notDetermined, ImportAccess.undetermined),
        (.authorized, .granted),
        (.limited, .granted),
        (.denied, .denied),
        (.restricted, .denied),
    ])
    func initWithAContactsStatusThenDecidesTheAccess(
        status: CNAuthorizationStatus,
        expected: ImportAccess
    ) {
        #expect(ImportAccess(status) == expected)
    }

    @Test(arguments: [
        (EKAuthorizationStatus.notDetermined, ImportAccess.undetermined),
        (.fullAccess, .granted),
        (.writeOnly, .denied),
        (.denied, .denied),
        (.restricted, .denied),
    ])
    func initWithACalendarStatusThenDecidesTheAccess(
        status: EKAuthorizationStatus,
        expected: ImportAccess
    ) {
        #expect(ImportAccess(status) == expected)
    }
}
