//
//  RelativeTimePhraseTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/09/05.
//

import Foundation
import Testing

@testable import DaysMarkCore

struct RelativeTimePhraseTests {
    @Test
    func partsThenSplitThePhraseAroundTheNumber() {
        // Given / When
        let parts = phrase("还有 12 天", number: "12").parts

        // Then
        #expect(parts == RelativeTimePhrase.Parts(leading: "还有", number: "12", trailing: "天"))
    }

    @Test
    func partsWhenTheNumberIsAtAnEdgeThenLeaveThatSideEmpty() {
        #expect(
            phrase("12 days ago", number: "12").parts
                == RelativeTimePhrase.Parts(leading: "", number: "12", trailing: "days ago")
        )
        #expect(
            phrase("Noch 12", number: "12").parts
                == RelativeTimePhrase.Parts(leading: "Noch", number: "12", trailing: "")
        )
    }

    @Test(arguments: [nil, "3"])
    func partsWhenThePhraseHoldsNoSuchNumberThenIsNil(number: String?) {
        #expect(phrase("Today", number: number).parts == nil)
    }

    @Test
    func partsWhenTheNumberIsGroupedThenKeepsItWhole() {
        // Given
        let number = 1024.formatted()

        // When
        let parts = phrase("In \(number) days", number: number).parts

        // Then
        #expect(parts?.number == number)
        #expect(parts?.trailing == "days")
    }

    @Test
    func updatedWithoutATargetDateThenIsUnchanged() {
        // Given
        let dayPhrase = RelativeTimePhrase(DayCount(days: 12, direction: .upcoming))

        // When
        let updated = dayPhrase.updated(at: .mockNow, locale: Locale(identifier: "en_US"))

        // Then
        #expect(updated == dayPhrase)
    }

    @Test
    func updatedWithATargetDateThenCountsFromTheNewMomentAndKeepsThePhase() {
        // Given
        let target = Date.mockNow.addingTimeInterval(2 * 60 * 60)
        let phrase = RelativeTimePhrase(
            text: "",
            number: nil,
            targetDate: target,
            phase: .ongoing
        )

        // When
        let updated = phrase.updated(
            at: target.addingTimeInterval(-30 * 60),
            locale: Locale(identifier: "en_US")
        )

        // Then
        #expect(updated.number == "30")
        #expect(updated.targetDate == target)
        #expect(updated.phase == .ongoing)
    }

    private func phrase(_ text: String, number: String?) -> RelativeTimePhrase {
        RelativeTimePhrase(text: text, number: number, targetDate: nil, phase: .point)
    }
}
