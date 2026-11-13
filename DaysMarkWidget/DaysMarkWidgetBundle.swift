//
//  DaysMarkWidgetBundle.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/07/31.
//

import SwiftUI
import WidgetKit

@main
struct DaysMarkWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusWidget()
        ListWidget()
        ImportantDateLiveActivityWidget()
    }
}
