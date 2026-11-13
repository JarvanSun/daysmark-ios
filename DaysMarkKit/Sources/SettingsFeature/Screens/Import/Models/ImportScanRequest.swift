//
//  ImportScanRequest.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

struct ImportScanRequest: Equatable {
    let id: UUID
    let source: ImportScanSource
    let defaultReminderTime: TimeOfDay
}
