//
//  ImportView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/09/04.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct ImportView: View {
    @Environment(\.dimensions) private var dimensions

    @AppStorage(NotificationPreferences.Key.newReminderMinuteOfDay.rawValue)
    private var newReminderMinuteOfDay = NotificationPreferences()
        .defaultNewReminderTime.minuteOfDay

    let viewModel: ImportViewModel

    var body: some View {
        PageScrollView {
            SettingsGroup(footnote: Text("settings.import.source.footnote", bundle: .module)) {
                Button {
                    scan(.contacts)
                } label: {
                    SettingsRow(
                        Text("settings.import.source.contacts", bundle: .module),
                        symbol: .personCropCircleBadgePlus,
                        showsDisclosure: true
                    )
                }

                Button {
                    scan(.calendar)
                } label: {
                    SettingsRow(
                        Text("settings.import.source.calendar", bundle: .module),
                        symbol: .calendarBadgePlus,
                        showsDisclosure: true
                    )
                }
            }
            .buttonStyle(.plain)

            switch viewModel.review {
            case .notScanned: EmptyView()
            case .nothingFound:
                ContentUnavailableView {
                    Label(Text("settings.import.emptyResult", bundle: .module), symbol: .tray)
                }
            case .candidates(let candidates):
                SettingsGroup(Text("settings.import.review.title", bundle: .module)) {
                    ForEach(candidates) { candidate in
                        ImportCandidateRow(candidate: candidate, viewModel: viewModel)
                            .padding(.vertical, dimensions.spaceMedium)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.review.candidates != nil {
                Button {
                    viewModel.importSelection()
                } label: {
                    Text("settings.import.confirm", bundle: .module)
                }
                .buttonStyle(.daysmark(.bar))
                .disabled(!viewModel.canImport)
                .padding()
                .background(.bar)
            }
        }
        .overlay {
            if viewModel.isScanning {
                ProgressView {
                    Text("settings.import.scanning", bundle: .module)
                }
            }
        }
        .navigationTitle(Text("settings.import.title", bundle: .module))
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() })
        .alert(
            Text("settings.import.completion.title", bundle: .module),
            isPresented: Binding(viewModel.activity == .imported) { _ in
                viewModel.acknowledgeImport()
            }
        ) {
            Button(role: .cancel, action: {}) {
                Text("settings.import.completion.done", bundle: .module)
            }
        } message: {
            Text("settings.import.completion.message", bundle: .module)
        }
        .task(id: viewModel.scanRequest) { await viewModel.loadCandidates() }
        .task(id: viewModel.applyRequest) { await viewModel.applySelection() }
    }

    private func scan(_ source: ImportScanSource) {
        viewModel.scan(source, defaultReminderTime: TimeOfDay(minuteOfDay: newReminderMinuteOfDay))
    }
}

#if DEBUG
#Preview("Import", arguments: ImportPreviewState.allCases) { state in
    NavigationStack {
        ImportView(viewModel: PreviewObjectPool().importViewModel(state))
    }
    .environment(\.locale, state.locale)
}
#endif
