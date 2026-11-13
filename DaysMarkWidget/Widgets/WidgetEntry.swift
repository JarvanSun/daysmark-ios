//
//  WidgetEntry.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import WidgetKit

struct WidgetEntry: TimelineEntry {
    let content: WidgetContent

    var date: Date {
        content.date
    }
}
