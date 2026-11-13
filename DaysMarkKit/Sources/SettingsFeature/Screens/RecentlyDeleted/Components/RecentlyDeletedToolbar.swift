//
//  RecentlyDeletedToolbar.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct RecentlyDeletedToolbar: ToolbarContent {
    let viewModel: RecentlyDeletedViewModel

    var body: some ToolbarContent {
        switch viewModel.isSelecting {
        case true: selecting
        case false: browsing
        }
    }

    @ToolbarContentBuilder
    private var selecting: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                viewModel.finishSelecting()
            } label: {
                Text("settings.recentlyDeleted.selection.done", bundle: .module)
            }
        }

        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                viewModel.selectAll()
            } label: {
                Text("settings.recentlyDeleted.selection.selectAll", bundle: .module)
            }

            Spacer()

            Button(role: .destructive) {
                viewModel.deleteSelectionPermanently()
            } label: {
                Label(
                    Text(
                        "settings.recentlyDeleted.selection.deletePermanently \(viewModel.selection.count)",
                        bundle: .module
                    ),
                    symbol: .trash
                )
            }
            .disabled(viewModel.selection.isEmpty)
            .labelStyle(.iconOnly)
            .tint(DaysMarkColor.destructiveControl.color)
        }
    }

    private var browsing: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.startSelecting()
            } label: {
                Text("settings.recentlyDeleted.selection.select", bundle: .module)
            }
            .disabled(viewModel.content.rows.isEmpty)
        }
    }
}
