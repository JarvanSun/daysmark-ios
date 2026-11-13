//
//  EventShareView.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct EventShareView: View {
    @Bindable var viewModel: EventShareViewModel

    var body: some View {
        Group {
            switch viewModel.content {
            case .some(let content):
                EventSharePanel(content: content, includesCategory: $viewModel.includesCategory)
            case nil:
                ContentUnavailableView {
                    Label(
                        Text("sharing.screen.unavailable", bundle: .module),
                        symbol: .calendarBadgeExclamationmark
                    )
                }
            }
        }
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .navigationTitle(Text("sharing.screen.title", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    viewModel.finish()
                } label: {
                    Text("sharing.screen.done", bundle: .module)
                }
            }
        }
        .tint(DaysMarkColor.tint.color)
        .task { await viewModel.observeStore() }
    }
}

#if DEBUG
#Preview("Sharing", arguments: EventsPreviewState.allCases) { state in
    let pool = PreviewObjectPool()

    NavigationStack {
        EventShareView(viewModel: pool.shareViewModel(state))
    }
    .environment(\.locale, state.locale)
}
#endif
