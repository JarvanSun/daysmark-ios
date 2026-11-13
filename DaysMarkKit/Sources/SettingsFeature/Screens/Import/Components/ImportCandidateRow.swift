//
//  ImportCandidateRow.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct ImportCandidateRow: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.locale) private var locale

    let candidate: ImportCandidate
    let viewModel: ImportViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceMedium) {
            Toggle(
                isOn: Binding(candidate.isSelected) {
                    viewModel.setSelection($0, for: candidate.id)
                }
            ) {
                VStack(alignment: .leading, spacing: dimensions.rowLineSpacing) {
                    Text(verbatim: candidate.result.item.title)
                        .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.eventTitle)

                    Text(verbatim: candidate.result.item.formattedDate(locale: locale))
                        .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.rowSecondary)

                    ImportStatusLabel(decision: candidate.result.decision)
                }
            }
            .disabled(!candidate.result.decision.isImportable)

            if candidate.needsResolution {
                Picker(
                    selection: Binding(candidate.resolution) {
                        viewModel.resolve(candidate.id, with: $0)
                    }
                ) {
                    Text("settings.import.conflict.keepMine", bundle: .module)
                        .tag(ImportResolution.keepMine)

                    Text("settings.import.conflict.useSource", bundle: .module)
                        .tag(ImportResolution.importSource)
                } label: {
                    Text("settings.import.conflict.menu", bundle: .module)
                }
                .pickerStyle(.segmented)
            }

            if let reminder = candidate.offeredReminder {
                ImportReminderOptions(
                    reminder: Binding(reminder) { viewModel.setReminder($0, for: candidate.id) }
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    let viewModel = PreviewObjectPool().importViewModel(.review)

    PageScrollView {
        ForEach(viewModel.review.candidates ?? []) { candidate in
            ImportCandidateRow(candidate: candidate, viewModel: viewModel)
        }
    }
}
#endif
