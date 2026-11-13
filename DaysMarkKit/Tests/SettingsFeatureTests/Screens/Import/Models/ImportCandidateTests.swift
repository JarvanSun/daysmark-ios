//
//  ImportCandidateTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Testing

@testable import SettingsFeature

struct ImportCandidateTests {
    @Test(arguments: [
        (ImportResult.mockConflict, true, true),
        (.mockConflict, false, false),
        (.mockNew, true, false),
    ])
    func needsResolutionThenHoldsForASelectedConflict(
        result: ImportResult,
        isSelected: Bool,
        expected: Bool
    ) {
        #expect(makeCandidate(result, isSelected: isSelected).needsResolution == expected)
    }

    @Test(arguments: [
        (ImportResult.mockNew, true, true),
        (.mockNew, false, false),
        (.mockChanged, true, false),
    ])
    func offeredReminderThenExistsForASelectedNewDate(
        result: ImportResult,
        isSelected: Bool,
        expected: Bool
    ) {
        #expect((makeCandidate(result, isSelected: isSelected).offeredReminder != nil) == expected)
    }

    private func makeCandidate(_ result: ImportResult, isSelected: Bool) -> ImportCandidate {
        .init(
            result: result,
            isSelected: isSelected,
            resolution: .keepMine,
            reminder: .init(isEnabled: true, daysBefore: 0, time: .mockNine)
        )
    }
}
