//
//  CategoryEditorView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/07/25.
//

import DesignSystem
import SwiftUI

struct CategoryEditorView: View {
    @FocusState private var isNameFocused: Bool

    @Bindable var viewModel: CategoryEditorViewModel

    var body: some View {
        List {
            Group {
                TextField(text: $viewModel.name) {
                    Text("settings.categories.editor.name", bundle: .module)
                }
                .focused($isNameFocused)
            }
            .listRowBackground(Color.clear)
            .listSectionSeparator(.hidden, edges: .top)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .navigationTitle(Text(viewModel.target.title))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    viewModel.cancel()
                } label: {
                    Text("settings.categories.editor.cancel", bundle: .module)
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    viewModel.save()
                } label: {
                    Text("settings.categories.editor.save", bundle: .module)
                }
                .disabled(!viewModel.canSave)
            }
        }
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() })
        .task { isNameFocused = true }
    }
}

#if DEBUG
#Preview("Category editor", arguments: SettingsPreviewState.allCases) { state in
    NavigationStack {
        CategoryEditorView(
            viewModel: PreviewObjectPool().categoryEditorViewModel(state.editorTarget)
        )
    }
    .environment(\.locale, state.locale)
}
#endif
