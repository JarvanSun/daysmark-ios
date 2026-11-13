//
//  ImportantDateActivityAttributesExtensions.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SwiftUI

extension ImportantDateActivityAttributes {
    var appearance: EventAppearance {
        EventAppearance(storedKey: symbolName)
    }
}

extension ImportantDateActivityAttributes.Target {
    var label: LocalizedStringKey {
        switch self {
        case .start: "liveActivity.time.start"
        case .end: "liveActivity.time.end"
        case .point: "liveActivity.time.point"
        }
    }
}
