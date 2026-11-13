//
//  DaysMarkImageTests.swift
//  DesignSystemTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing
import UIKit

@testable import DesignSystem

struct DaysMarkImageTests {
    @Test(arguments: DaysMarkImage.allCases)
    func namesASystemSymbol(image: DaysMarkImage) {
        #expect(UIImage(systemName: image.rawValue) != nil)
    }
}
