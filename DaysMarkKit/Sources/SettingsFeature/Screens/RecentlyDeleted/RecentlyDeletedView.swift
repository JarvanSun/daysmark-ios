//
//  RecentlyDeletedView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/09/03.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct RecentlyDeletedView: View {
    @Bindable var viewModel: RecentlyDeletedViewModel

    var body: some View {
        List(selection: $viewModel.selection) {
            ForEach(viewModel.content.rows) { row in
                DeletedEventRowView(row: row)
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.restore(row.id)
                        } label: {
                            Text("settings.recentlyDeleted.row.restore", bundle: .module)
                        }
                        .tint(DaysMarkColor.tint.color)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deletePermanently(row.id)
                        } label: {
                            Text("settings.recentlyDeleted.row.deletePermanently", bundle: .module)
                        }
                    }
                    .listRowBackground(row.background)
            }

            if !viewModel.content.rows.isEmpty {
                Text("settings.recentlyDeleted.footnote", bundle: .module)
                    .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.footnote)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .overlay {
            if viewModel.content.rows.isEmpty {
                ContentUnavailableView {
                    Label(
                        Text("settings.recentlyDeleted.empty.title", bundle: .module),
                        symbol: .trash
                    )
                } description: {
                    Text("settings.recentlyDeleted.empty.message", bundle: .module)
                }
            }
        }
        .navigationTitle(Text(viewModel.title))
        .environment(\.editMode, editMode)
        .toolbar { RecentlyDeletedToolbar(viewModel: viewModel) }
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() })
        .task { await viewModel.observeStore() }
    }

    private var editMode: Binding<EditMode> {
        Binding(viewModel.isSelecting ? .active : .inactive) {
            viewModel.isSelecting = $0.isEditing
        }
    }
}

#if DEBUG
#Preview("Recently Deleted", arguments: SettingsPreviewState.allCases) { state in
    NavigationStack {
        RecentlyDeletedView(viewModel: PreviewObjectPool().recentlyDeletedViewModel(state.contents))
    }
    .environment(\.locale, state.locale)
}
#endif
