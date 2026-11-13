//
//  EventEditorDeleteSection.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct EventEditorDeleteSection: View {
    @State private var isConfirming = false

    let onDelete: () -> Void

    var body: some View {
        Section {
            Button(role: .destructive) {
                isConfirming = true
            } label: {
                Text("editor.delete.button", bundle: .module)
                    .frame(maxWidth: .infinity)
            }
            .confirmationDialog(
                Text("editor.delete.confirmation.title", bundle: .module),
                isPresented: $isConfirming,
                titleVisibility: .hidden
            ) {
                Button(role: .destructive, action: onDelete) {
                    Text("editor.delete.confirmation.move", bundle: .module)
                }
            }
        }
    }
}
