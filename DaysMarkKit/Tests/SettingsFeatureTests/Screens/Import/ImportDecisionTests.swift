//
//  ImportDecisionTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation
import Testing

@testable import SettingsFeature

struct ImportDecisionTests {
    @Test(arguments: [
        (ImportDecision.create, true),
        (.change, true),
        (.conflict, true),
        (.unchanged, false),
        (.deleted, false),
    ])
    func isImportableThenHoldsForNewChangedAndConflictingDates(
        decision: ImportDecision,
        expected: Bool
    ) {
        #expect(decision.isImportable == expected)
    }

    @Test(arguments: [
        (ImportDecision.create, "settings.import.decision.new"),
        (.change, "settings.import.decision.changed"),
        (.conflict, "settings.import.decision.conflict"),
        (.unchanged, "settings.import.decision.unchanged"),
        (.deleted, "settings.import.decision.deleted"),
    ])
    func statusThenNamesTheDecision(decision: ImportDecision, key: String) {
        #expect(decision.status.key == key)
    }

    @Test(arguments: [
        (ImportDecision.create, true),
        (.change, true),
        (.conflict, false),
        (.unchanged, false),
        (.deleted, false),
    ])
    func statusColorThenIsTheTintOnlyForWhatWillChange(decision: ImportDecision, isTinted: Bool) {
        #expect((decision.statusColor == DaysMarkColor.tint) == isTinted)
    }

    @Test(arguments: [
        (ImportDecision.conflict, DaysMarkImage.exclamationmarkTriangle as DaysMarkImage?),
        (.create, nil),
        (.change, nil),
        (.unchanged, nil),
        (.deleted, nil),
    ])
    func statusSymbolThenWarnsOnlyAboutAConflict(decision: ImportDecision, symbol: DaysMarkImage?) {
        #expect(decision.statusSymbol == symbol)
    }
}
