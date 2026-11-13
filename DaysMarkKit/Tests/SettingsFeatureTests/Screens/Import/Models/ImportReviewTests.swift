//
//  ImportReviewTests.swift
//  SettingsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import SettingsFeature

struct ImportReviewTests {
    @Test(arguments: [ImportReview.notScanned, .nothingFound])
    func candidatesWithoutAReviewThenIsNil(review: ImportReview) {
        #expect(review.candidates == nil)
    }

    @Test func candidatesWhenReviewingThenReturnsThem() {
        #expect(ImportReview.candidates([]).candidates == [])
    }
}
