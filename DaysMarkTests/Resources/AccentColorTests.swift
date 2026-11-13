//
//  AccentColorTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI
import Testing
import UIKit

@testable import DaysMark
@testable import DesignSystem

struct AccentColorTests {
    let appearances: [UITraitCollection] = [
        UITraitCollection { $0.userInterfaceStyle = .light },
        UITraitCollection { $0.userInterfaceStyle = .dark },
        UITraitCollection {
            $0.userInterfaceStyle = .light
            $0.accessibilityContrast = .high
        },
        UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.accessibilityContrast = .high
        },
    ]

    @Test
    func accentAssetMatchesTintToken() {
        let asset = UIColor(
            named: "AccentColor",
            in: Bundle(for: AppRootViewModel.self),
            compatibleWith: nil
        )
        #expect(asset != nil)
        guard let asset else { return }

        for traits in appearances {
            let resolved = asset.resolvedColor(with: traits)
            let expected = UIColor(DaysMarkColor.tint.color).resolvedColor(with: traits)

            #expect(
                approximatelyEqual(resolved, expected),
                "AccentColor \(traits) \(hexString(resolved)) != \(hexString(expected))"
            )
        }
    }

    private func approximatelyEqual(_ lhs: UIColor, _ rhs: UIColor) -> Bool {
        var l = (r: CGFloat(0), g: CGFloat(0), b: CGFloat(0), a: CGFloat(0))
        var r = l
        lhs.getRed(&l.r, green: &l.g, blue: &l.b, alpha: &l.a)
        rhs.getRed(&r.r, green: &r.g, blue: &r.b, alpha: &r.a)
        return abs(l.r - r.r) < 0.01 && abs(l.g - r.g) < 0.01 && abs(l.b - r.b) < 0.01
    }

    private func hexString(_ color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
