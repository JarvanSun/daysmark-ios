//
//  AppCommands.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/10/07.
//

import DaysMarkCore
import SwiftUI

struct AppCommands: Commands {
    @FocusedValue(\.appRequest) private var request

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button(action: { request?.wrappedValue = .newEvent }) {
                Text("app.commands.addEvent")
            }
            .keyboardShortcut("n")
            .disabled(request == nil)
        }

        CommandGroup(after: .textEditing) {
            Button(action: { request?.wrappedValue = .search }) {
                Text("app.commands.search")
            }
            .keyboardShortcut("f", modifiers: [.command, .option])
            .disabled(request == nil)
        }
    }
}
