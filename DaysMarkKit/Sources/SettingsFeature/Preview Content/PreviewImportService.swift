//
//  PreviewImportService.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import DaysMarkCore

struct PreviewImportService: ImportScanning, ImportApplying {
    let results: [ImportResult]

    func scan(_ source: ImportScanSource) async throws(ImportError) -> [ImportResult] {
        results
    }

    func apply(
        _ results: [ImportResult],
        resolutions: [String: ImportResolution],
        reminders: [String: ImportReminderConfiguration]
    ) async throws(ImportError) {}
}
#endif
