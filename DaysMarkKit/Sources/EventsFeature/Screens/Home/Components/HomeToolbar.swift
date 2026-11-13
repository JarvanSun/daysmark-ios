//
//  HomeToolbar.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct HomeToolbar: ToolbarContent {
    let viewModel: HomeViewModel
    let canSelect: Bool
    let showsAddAndSearch: Bool

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
                Text("home.selection.done", bundle: .module)
            }
        }

        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.selectAll()
            } label: {
                Text("home.selection.selectAll", bundle: .module)
            }
        }

        ToolbarSpacer(.flexible, placement: .bottomBar)

        ToolbarItem(placement: .bottomBar) {
            Button(role: .destructive) {
                viewModel.deleteSelection()
            } label: {
                Label(
                    Text("home.selection.delete \(viewModel.selection.count)", bundle: .module),
                    symbol: .trash
                )
            }
            .disabled(viewModel.selection.isEmpty)
            .labelStyle(.iconOnly)
            .tint(DaysMarkColor.destructiveControl.color)
        }

        DefaultToolbarItem(kind: .search, placement: .bottomBar)
    }

    @ToolbarContentBuilder
    private var browsing: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.openSettings()
            } label: {
                Label(Text("home.toolbar.settings", bundle: .module), symbol: .gearshape)
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.startSelecting()
            } label: {
                Text("home.selection.select", bundle: .module)
            }
            .disabled(!canSelect)
        }

        if showsAddAndSearch {
            ToolbarSpacer(.fixed, placement: .primaryAction)

            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.addEvent()
                } label: {
                    Label(Text("home.toolbar.add", bundle: .module), symbol: .plus)
                }
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

            DefaultToolbarItem(kind: .search, placement: .bottomBar)
        }
    }
}
