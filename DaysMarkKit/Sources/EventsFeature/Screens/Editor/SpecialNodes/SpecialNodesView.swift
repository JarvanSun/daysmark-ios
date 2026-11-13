//
//  SpecialNodesView.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct SpecialNodesView: View {
    let viewModel: EventEditorViewModel

    var body: some View {
        List {
            Group {
                Section {
                    Toggle(
                        isOn: Binding(viewModel.hasSpecialNodeTime) {
                            viewModel.toggleSpecialNodeTime($0)
                        }
                    ) {
                        SettingsLabel(
                            title: Text("editor.specialNodes.time.toggle", bundle: .module),
                            symbol: .bell
                        )
                    }

                    if viewModel.hasSpecialNodeTime {
                        ReminderTimePicker(
                            minuteOfDay: viewModel.specialNodeTime.minuteOfDay,
                            onChange: { viewModel.setSpecialNodeTime(TimeOfDay(minuteOfDay: $0)) }
                        ) {
                            SettingsLabel(title: Text("editor.date.time", bundle: .module))
                        }
                    }
                } footer: {
                    Text("editor.specialNodes.footnote", bundle: .module)
                        .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.footnote)
                }

                ForEach(SpecialReminderNodeKind.allCases, id: \.self) { kind in
                    Section {
                        ForEach(viewModel.specialNodeChoices(of: kind)) { choice in
                            SpecialNodeChoiceRow(choice: choice) {
                                viewModel.toggleSpecialNode(choice.preset)
                            }
                        }
                    } header: {
                        Text(kind.groupTitle)
                    }
                }
            }
            .listRowBackground(Color.clear)
            .listSectionSeparator(.hidden, edges: .top)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .tint(DaysMarkColor.tint.color)
        .navigationTitle(Text("editor.specialNodes.title", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG
#Preview("Special Nodes", arguments: SpecialNodesPreviewState.allCases) { state in
    NavigationStack {
        SpecialNodesView(viewModel: PreviewObjectPool().specialNodesViewModel(state))
    }
    .environment(\.locale, state.locale)
}
#endif
