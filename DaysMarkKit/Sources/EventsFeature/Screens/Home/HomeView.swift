//
//  HomeView.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/07/25.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct HomeView: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.eventZoomNamespace) private var zoomNamespace

    @Bindable var viewModel: HomeViewModel
    @Binding var request: AppRequest?

    var body: some View {
        List(selection: $viewModel.selection) {
            if viewModel.content.showsOverview {
                HomeHeader(viewModel: viewModel)
            }

            ForEach(viewModel.content.rows) { row in
                Button {
                    viewModel.open(row.id)
                } label: {
                    EventRow(event: row.event, showsDisclosure: !isSidebar)
                }
                .zoomSource(id: EventZoomSource(eventID: row.id, isFocus: false), in: zoomNamespace)
                .swipeActions(edge: .leading) {
                    PinButton(pinAction: row.pinAction) { viewModel.togglePin(row.id) }
                }
                .swipeActions(edge: .trailing) {
                    DeleteButton { viewModel.delete(row.id) }
                    ShareButton { viewModel.share(row.id) }
                }
                .listRowBackground(Color.clear)
            }

            if let placeholder = viewModel.content.placeholder {
                HomeEmptyView(
                    placeholder: placeholder,
                    onAdd: { viewModel.addEvent() },
                    onResetFilters: { viewModel.resetFilters() }
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .environment(\.editMode, editMode)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            HomeToolbar(
                viewModel: viewModel,
                canSelect: !viewModel.content.selectableIDs.isEmpty,
                showsAddAndSearch: !isSidebar
            )
        }
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() })
        .refreshes(viewModel.time, at: viewModel.content.nextChange)
        .handles($request) { viewModel.open($0) }
        .task { await viewModel.observeStore() }
    }

    private var isSidebar: Bool {
        horizontalSizeClass == .regular
    }

    private var editMode: Binding<EditMode> {
        Binding(viewModel.isSelecting ? .active : .inactive) {
            viewModel.isSelecting = $0.isEditing
        }
    }
}

#if DEBUG
#Preview("Home", arguments: EventsPreviewState.allCases) { state in
    @Previewable @State var request: AppRequest?

    NavigationStack {
        HomeView(
            viewModel: PreviewObjectPool().homeViewModel(state),
            request: $request
        )
    }
    .environment(\.locale, state.locale)
}
#endif
