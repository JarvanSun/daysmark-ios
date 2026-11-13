//
//  EventsDestinationView.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import Foundation
import SettingsFeature
import SunUserInterface
import SwiftUI

struct EventsDestinationView: FeatureDestinationView {
    let destination: EventsDestination
    let dependencies: EventsDependencies
    let router: EventsRouting
    let editorViewModel: EventEditorViewModel?

    var style: PresentingStyle {
        switch destination {
        case .editor, .sharing: .sheet
        case .root, .detail, .settings, .specialNodes: .push
        }
    }

    var body: some View {
        switch destination {
        case .root: EmptyView()
        case .detail(let id, let fromFocus): detail(for: id, fromFocus: fromFocus)
        case .settings(let page): SettingsHostView(dependencies: dependencies.settings, page: page)
        case .editor: editor
        case .specialNodes: specialNodes
        case .sharing(let id): sharing(for: id)
        }
    }

    @ViewBuilder
    private var editor: some View {
        switch editorViewModel {
        case .some(let viewModel): EventEditorView(viewModel: viewModel).presentationSizing(.form)
        case nil: EmptyView()
        }
    }

    @ViewBuilder
    private var specialNodes: some View {
        switch editorViewModel {
        case .some(let viewModel): SpecialNodesView(viewModel: viewModel)
        case nil: EmptyView()
        }
    }

    private func detail(for id: CountdownEvent.ID, fromFocus: Bool) -> some View {
        ViewModelOwner(dependencies.makeDetailViewModel(eventID: id, router: router)) {
            EventDetailView(viewModel: $0, zoomSource: .init(eventID: id, isFocus: fromFocus))
        }
    }

    private func sharing(for id: CountdownEvent.ID) -> some View {
        ViewModelOwner(dependencies.makeShareViewModel(eventID: id, router: router)) {
            EventShareView(viewModel: $0)
        }
        .presentationSizing(.form)
    }
}

private struct ViewModelOwner<ViewModel, Screen: View>: View {
    @State private var viewModel: ViewModel

    private let screen: (ViewModel) -> Screen

    init(
        _ viewModel: @autoclosure () -> ViewModel,
        @ViewBuilder screen: @escaping (ViewModel) -> Screen
    ) {
        _viewModel = State(initialValue: viewModel())
        self.screen = screen
    }

    var body: some View {
        screen(viewModel)
    }
}
