//
//  EventEditorView.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct EventEditorView: View {
    @FocusState private var isTitleFocused: Bool

    @Bindable var viewModel: EventEditorViewModel

    var body: some View {
        List {
            Group {
                Section {
                    if let preview = viewModel.preview {
                        EventEditorPreviewRow(preview: preview)
                    }

                    TextField(text: $viewModel.draft.title, axis: .vertical) {
                        Text("editor.titleField.placeholder", bundle: .module)
                    }
                    .submitLabel(.done)
                    .font(DaysMarkFont.heroTitle)
                    .focused($isTitleFocused)
                }

                EventEditorDateSection(viewModel: viewModel)

                Section {
                    Picker(selection: $viewModel.draft.categoryID) {
                        ForEach(viewModel.categoryChoices) { category in
                            Text(verbatim: category.displayName)
                                .tag(category.id)
                        }
                    } label: {
                        SettingsLabel(
                            title: Text("editor.category.title", bundle: .module),
                            symbol: .folder
                        )
                    }
                }

                EventEditorRulesSection(viewModel: viewModel)

                EventEditorAppearanceSection(selection: $viewModel.draft.icon)

                Section {
                    Toggle(
                        isOn: Binding(!viewModel.draft.isSpotlightHidden) {
                            viewModel.draft.isSpotlightHidden = !$0
                        }
                    ) {
                        SettingsLabel(
                            title: Text("editor.privacy.spotlight", bundle: .module),
                            symbol: .magnifyingglass
                        )
                    }
                } header: {
                    Text("editor.privacy.title", bundle: .module)
                }

                if !viewModel.isNew {
                    EventEditorDeleteSection(onDelete: { viewModel.delete() })
                }
            }
            .listRowBackground(Color.clear)
            .listSectionSeparator(.hidden, edges: .top)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .scrollDismissesKeyboard(.immediately)
        .tint(DaysMarkColor.tint.color)
        .navigationTitle(Text(viewModel.title))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EventEditorToolbar(viewModel: viewModel) }
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() })
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges)
        .task { isTitleFocused = viewModel.isNew }
        .task { await viewModel.observeStore() }
        .task(id: viewModel.permissionRequest) {
            await viewModel.requestNotificationPermission()
        }
    }
}

#if DEBUG
#Preview("Editor", arguments: EventsPreviewState.allCases) { state in
    let pool = PreviewObjectPool()
    let container = pool.modelContainer(state.contents)

    NavigationStack {
        EventEditorView(viewModel: pool.editorViewModel(state, in: container))
    }
    .environment(\.locale, state.locale)
}
#endif
