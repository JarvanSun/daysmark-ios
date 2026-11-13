//
//  CategoriesView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/07/25.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct CategoriesView: View {
    let viewModel: CategoriesViewModel

    var body: some View {
        List {
            ForEach(viewModel.content.rows) { row in
                CategoryRowView(row: row, onRename: { viewModel.rename(row) })
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if !row.isBuiltIn {
                            Button(role: .destructive) {
                                viewModel.delete(row)
                            } label: {
                                Label(
                                    Text("settings.categories.row.delete", bundle: .module),
                                    symbol: .trash
                                )
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
            }
            .onMove { viewModel.move(from: $0, to: $1) }

            Text("settings.categories.footnote", bundle: .module)
                .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.footnote)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .navigationTitle(Text("settings.categories.title", bundle: .module))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.addCategory()
                } label: {
                    Label(Text("settings.categories.add", bundle: .module), symbol: .plus)
                }
            }
        }
        .confirmationDialog(
            Text(
                "settings.categories.deletion.title \(viewModel.pendingDeletion?.name ?? "")",
                bundle: .module
            ),
            isPresented: Binding(
                isPresenting: viewModel.pendingDeletion,
                onDismiss: { viewModel.cancelDeletion() }
            ),
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                viewModel.confirmDeletion()
            } label: {
                Text("settings.categories.deletion.confirm", bundle: .module)
            }

            Button(role: .cancel) {
                viewModel.cancelDeletion()
            } label: {
                Text("settings.categories.deletion.cancel", bundle: .module)
            }
        } message: {
            Text(
                "settings.categories.deletion.message \(BuiltInCategory.important.displayName)",
                bundle: .module
            )
        }
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() })
        .task { await viewModel.observeStore() }
    }
}

#if DEBUG
#Preview("Categories", arguments: SettingsPreviewState.allCases) { state in
    NavigationStack {
        CategoriesView(viewModel: PreviewObjectPool().categoriesViewModel(state.contents))
    }
    .environment(\.locale, state.locale)
}
#endif
