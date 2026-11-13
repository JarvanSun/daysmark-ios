//
//  ImportActivity.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

enum ImportActivity: Equatable {
    case idle
    case scanning(ImportScanSource)
    case reviewing
    case applying
    case imported
}
