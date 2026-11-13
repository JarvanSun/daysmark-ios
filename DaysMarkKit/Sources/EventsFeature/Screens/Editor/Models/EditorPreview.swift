//
//  EditorPreview.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation
import SwiftUI

struct EditorPreview: Equatable {
    let title: String
    let dayCount: DayCount

    private var shownTitle: String {
        title.isEmpty ? String(localized: "editor.preview.untitled", bundle: .module) : title
    }

    private var phrase: String {
        switch dayCount.direction {
        case .upcoming:
            String(localized: "editor.preview.title.upcoming \(shownTitle)", bundle: .module)
        case .past: String(localized: "editor.preview.title.past \(shownTitle)", bundle: .module)
        case .today: String(localized: "editor.preview.title.today \(shownTitle)", bundle: .module)
        }
    }
}

extension EditorPreview {
    var tint: DaysMarkColor { dayCount.direction.tint }

    var countsDown: Bool { dayCount.direction == .upcoming }

    var number: Text {
        switch dayCount.direction {
        case .today: Text("editor.preview.today", bundle: .module)
        case .upcoming, .past: Text(verbatim: dayCount.days.formatted())
        }
    }

    var unit: LocalizedStringResource? {
        switch (dayCount.direction, dayCount.days) {
        case (.today, _): nil
        case (_, 1): LocalizedStringResource("editor.preview.unit.day", bundle: .module)
        case (_, _): LocalizedStringResource("editor.preview.unit.days", bundle: .module)
        }
    }

    var sentence: AttributedString {
        var sentence = AttributedString(phrase)
        sentence.foregroundColor = DaysMarkColor.textSecondary.color

        if let range = sentence.range(of: shownTitle) {
            sentence[range].foregroundColor = DaysMarkColor.textPrimary.color
            sentence[range].font = DaysMarkFont.previewSentenceEmphasis.font
        }

        return sentence
    }

    var accessibilityLabel: String {
        switch dayCount.direction {
        case .today:
            String(
                localized: "editor.preview.accessibilityLabel.today \(shownTitle)",
                bundle: .module
            )
        case .upcoming, .past: dayCount.accessibilityLabel(title: shownTitle)
        }
    }
}
