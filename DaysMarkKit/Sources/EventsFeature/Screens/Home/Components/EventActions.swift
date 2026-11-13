//
//  EventActions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct PinButton: View {
    let pinAction: PinAction
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(Text(pinAction.title), symbol: pinAction.rowSymbol)
        }
    }
}

struct ShareButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(Text("home.row.share", bundle: .module), symbol: .squareAndArrowUp)
        }
    }
}

struct DeleteButton: View {
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Label(Text("home.row.delete", bundle: .module), symbol: .trash)
        }
        .accessibilityLabel(Text("home.row.delete.accessibilityLabel", bundle: .module))
    }
}
