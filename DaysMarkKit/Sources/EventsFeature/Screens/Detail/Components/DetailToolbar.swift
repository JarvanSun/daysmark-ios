//
//  DetailToolbar.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct DetailToolbar: ToolbarContent {
    let viewModel: EventDetailViewModel

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                viewModel.togglePin()
            } label: {
                Label(
                    Text(viewModel.content.pinAction.title),
                    symbol: viewModel.content.pinAction.toolbarSymbol
                )
            }
            .contentTransition(.symbolEffect(.replace))
            .sensoryFeedback(.impact(weight: .medium), trigger: viewModel.content.pinAction)

            Button {
                viewModel.edit()
            } label: {
                Text("detail.toolbar.edit", bundle: .module)
            }
        }
    }
}
