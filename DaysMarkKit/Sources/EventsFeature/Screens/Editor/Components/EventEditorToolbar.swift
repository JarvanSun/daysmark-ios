//
//  EventEditorToolbar.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct EventEditorToolbar: ToolbarContent {
    let viewModel: EventEditorViewModel

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .cancel) {
                viewModel.cancel()
            } label: {
                Label(Text("editor.toolbar.cancel", bundle: .module), symbol: .xmark)
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button {
                viewModel.save()
            } label: {
                Label(Text("editor.toolbar.save", bundle: .module), symbol: .checkmark)
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canSave)
        }
    }
}
