//
//  EventsNavigationHost.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/07/25.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct EventsNavigationHost: FeatureHost {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Namespace private var zoomNamespace
    @State private var router: EventsRouter
    @State private var homeViewModel: HomeViewModel
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @Binding private var request: AppRequest?

    var featureRouter: EventsRouter { router }

    var root: some View {
        HomeView(viewModel: homeViewModel, request: $request)
            .searchable(
                text: $homeViewModel.filter.searchText,
                isPresented: $homeViewModel.isSearchPresented,
                prompt: Text("home.search.prompt", bundle: .module)
            )
            .searchToolbarBehavior(.minimize)
    }

    var body: some View {
        layout
            .onChange(of: horizontalSizeClass, initial: true) { _, sizeClass in
                router.showsSplitView = sizeClass == .regular
            }
    }

    init(dependencies: EventsDependencies, request: Binding<AppRequest?>) {
        let router = EventsRouter(dependencies: dependencies)

        _router = State(initialValue: router)
        _homeViewModel = State(initialValue: dependencies.makeHomeViewModel(router: router))
        _request = request
    }

    @ViewBuilder
    private var layout: some View {
        switch horizontalSizeClass {
        case .regular: splitLayout
        default: stackLayout
        }
    }

    private var stackLayout: some View {
        Navigator(
            path: $router.path,
            presentation: $router.presentation,
            root: { root },
            destination: { router.view(for: $0) }
        )
        .environment(\.eventZoomNamespace, zoomNamespace)
    }

    private var splitLayout: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            detailColumn
        }
        .searchable(
            text: $homeViewModel.filter.searchText,
            isPresented: $homeViewModel.isSearchPresented,
            prompt: Text("home.search.prompt", bundle: .module)
        )
        .onChange(of: homeViewModel.isSearchPresented) { _, isPresented in
            revealSidebar(whenSearching: isPresented)
        }
        .featurePresentation(router)
    }

    private var sidebar: some View {
        NavigationStack {
            HomeView(
                viewModel: homeViewModel,
                request: $request
            )
        }
        .navigationSplitViewColumnWidth(
            min: dimensions.sidebarMinimumWidth,
            ideal: dimensions.sidebarIdealWidth,
            max: dimensions.sidebarMaximumWidth
        )
    }

    private var detailColumn: some View {
        NavigationStack(path: $router.detailPath) {
            selectedScreen
                .navigationDestination(
                    for: EventsDestination.self,
                    destination: { router.view(for: $0) }
                )
                .toolbar {
                    ToolbarSpacer(.fixed, placement: .primaryAction)

                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { homeViewModel.addEvent() }) {
                            Label(Text("home.toolbar.add", bundle: .module), symbol: .plus)
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private var selectedScreen: some View {
        switch router.selection {
        case .some(let selection): router.view(for: selection).id(selection)
        case nil: SplitDetailPlaceholder()
        }
    }

    private func revealSidebar(whenSearching isSearching: Bool) {
        guard isSearching else { return }

        columnVisibility = .all
    }
}

private struct SplitDetailPlaceholder: View {
    var body: some View {
        ContentUnavailableView {
            Label(Text("home.detail.placeholder", bundle: .module), symbol: .calendar)
        }
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
    }
}
