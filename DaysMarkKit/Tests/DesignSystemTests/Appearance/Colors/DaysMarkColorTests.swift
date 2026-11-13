//
//  DaysMarkColorTests.swift
//  DesignSystemTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI
import Testing
import UIKit

@testable import DesignSystem

struct DaysMarkColorTests {
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
    let expectedValues: [(DaysMarkColor, [String])] = [
        (DaysMarkColor.canvas, ["F7F3EC", "141311", "F7F3EC", "141311"]),
        (DaysMarkColor.canvasSecondary, ["EFE9DF", "1D1B17", "EFE9DF", "1D1B17"]),
        (DaysMarkColor.textPrimary, ["2A2724", "ECE7DE", "1A1816", "F7F3EC"]),
        (DaysMarkColor.textSecondary, ["6B655C", "A8A196", "4E4941", "C9C2B6"]),
        (DaysMarkColor.textTertiary, ["9C958A", "6F6A62", "6B655C", "A8A196"]),
        (DaysMarkColor.separator, ["E2DCD1", "2A2823", "B9B1A3", "4D4941"]),
        (DaysMarkColor.destructive, ["B3423A", "E6857D", "8C2F29", "F0A9A3"]),
        (DaysMarkColor.tint, ["2F5D3A", "8FBF97", "22452B", "B4DDBB"]),
        (DaysMarkColor.tintSoft, ["DCE8DD", "203527", "CBDDCE", "27422F"]),
        (DaysMarkColor.upcoming, ["2F5D3A", "8FBF97", "22452B", "B4DDBB"]),
        (DaysMarkColor.textOnTint, ["FFFFFF", "141311", "FFFFFF", "141311"]),
        (DaysMarkColor.past, ["9A5A3C", "D19A78", "7C4429", "E3B89E"]),
        (DaysMarkColor.landscapePastGround, ["F4EBDC", "756651", "F4EBDC", "99856B"]),
        (DaysMarkColor.landscapeFutureGround, ["EBEEDA", "69785A", "EBEEDA", "899C76"]),
        (DaysMarkColor.landscapePastFoliage, ["E5D4BA", "B6A087", "E5D4BA", "D2BCA1"]),
        (DaysMarkColor.landscapeFutureFoliage, ["DAE3C8", "A4B38D", "DAE3C8", "C0CEA9"]),
    ]

    @Test
    func resolvesToItsValueInEveryAppearance() {
        for (color, hexes) in expectedValues {
            for (traits, hex) in zip(appearances, hexes) {
                let resolved = color.uiColor.resolvedColor(with: traits)

                #expect(rgba(of: resolved) == rgba(hex: hex), "\(color) \(traits)")
            }
        }
    }

    @Test
    func everyColorHasAnExpectedValue() {
        let covered = Set(expectedValues.map(\.0)).union([.caution, .destructiveControl])

        #expect(covered == Set(DaysMarkColor.allCases))
    }

    @Test
    func textColorsReachAAOnBothCanvases() {
        for text in [DaysMarkColor.textPrimary, .textSecondary, .tint, .past] {
            for traits in appearances {
                let ratio = contrast(text, .canvas, in: traits)

                #expect(ratio >= 4.5, "\(text) on canvas \(traits): \(ratio)")
            }
        }

        for traits in appearances {
            #expect(contrast(.textSecondary, .canvasSecondary, in: traits) >= 4.5)
        }
    }

    @Test
    func increasedContrastIsNeverWeaker() {
        for text in [DaysMarkColor.textPrimary, .textSecondary, .tint, .past] {
            #expect(
                contrast(text, .canvas, in: appearances[2])
                    >= contrast(text, .canvas, in: appearances[0])
            )
            #expect(
                contrast(text, .canvas, in: appearances[3])
                    >= contrast(text, .canvas, in: appearances[1])
            )
        }
    }

    @Test
    func cautionIsTheSystemOrange() {
        for traits in appearances {
            let resolved = DaysMarkColor.caution.uiColor.resolvedColor(with: traits)
            let orange = UIColor.systemOrange.resolvedColor(with: traits)

            #expect(rgba(of: resolved) == rgba(of: orange))
        }
    }

    @Test
    func destructiveControlIsTheSystemRed() {
        for traits in appearances {
            let resolved = DaysMarkColor.destructiveControl.uiColor.resolvedColor(with: traits)
            let red = UIColor.systemRed.resolvedColor(with: traits)

            #expect(rgba(of: resolved) == rgba(of: red))
        }
    }
}

private extension DaysMarkColorTests {
    func rgba(of color: UIColor) -> [Int] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return [red, green, blue, alpha].map { Int(($0 * 255).rounded()) }
    }

    func contrast(_ a: DaysMarkColor, _ b: DaysMarkColor, in traits: UITraitCollection) -> Double {
        let first = luminance(a.uiColor.resolvedColor(with: traits))
        let second = luminance(b.uiColor.resolvedColor(with: traits))

        return (max(first, second) + 0.05) / (min(first, second) + 0.05)
    }

    func luminance(_ color: UIColor) -> Double {
        let channels = rgba(of: color).prefix(3).map { value in
            let channel = Double(value) / 255

            return channel <= 0.03928 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]
    }

    func rgba(hex: String) -> [Int] {
        let value = Int(hex, radix: 16) ?? 0

        return [(value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF, 255]
    }
}
