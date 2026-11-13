//
//  EventsRouter.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation
import Observation
import SunUserInterface

@Observable
final class EventsRouter: FeatureRouting, EventsRouting {
    var presentation: FeaturePresentation<EventsDestination>?
    var path: [EventsDestination] = []
    var showsSplitView = false

    private(set) var editorViewModel: EventEditorViewModel?

    private let dependencies: EventsDependencies

    var isPresentingSheet: Bool { presentation != nil }

    var selection: EventsDestination? { path.first }

    var selectedEventID: CountdownEvent.ID? {
        switch selection {
        case .detail(let id, _): id
        default: nil
        }
    }

    var detailPath: [EventsDestination] {
        get { Array(path.dropFirst()) }
        set {
            guard let selection else { return }

            path = [selection] + newValue
        }
    }

    init(dependencies: EventsDependencies) {
        self.dependencies = dependencies
    }

    func view(for destination: EventsDestination) -> EventsDestinationView {
        .init(
            destination: destination,
            dependencies: dependencies,
            router: self,
            editorViewModel: editorViewModel
        )
    }

    func showHome() {
        path = []
    }

    func showDetail(for id: CountdownEvent.ID) {
        show(.detail(id, fromFocus: false))
    }

    func showDetailFromFocus(for id: CountdownEvent.ID) {
        show(.detail(id, fromFocus: true))
    }

    func showSettings(_ page: SettingsPage) {
        show(.settings(page))
    }

    func showEditor(for target: EditorTarget) {
        editorViewModel = dependencies.makeEditorViewModel(target: target, router: self)
        present(.editor(target))
    }

    func showSpecialNodes() {
        presentation?.navigation.path.append(.specialNodes)
    }

    func showSharing(for id: CountdownEvent.ID) {
        present(.sharing(id))
    }

    func showRequestedDetail(for id: CountdownEvent.ID) {
        open(.detail(id, fromFocus: false), context: requestContext)
    }

    func showRequestedSettings(_ page: SettingsPage) {
        open(.settings(page), context: requestContext)
    }

    func closeDetail(for id: CountdownEvent.ID) {
        path.removeAll { $0.shows(sameScreenAs: .detail(id, fromFocus: false)) }
    }

    func dismissSheet() {
        presentation = nil
        editorViewModel = nil
    }

    func open(_ destination: EventsDestination, context: RequestContext) {
        guard !isEditing(destination) else { return }
        guard !isPresentingSheet else { return }

        switch (view(for: destination).style, context) {
        case (.sheet, .coldStart): presentOverHome(destination)
        case (.sheet, .activeSession): showSheet(destination)
        case (_, .coldStart): path = [destination]
        case (_, .activeSession): push(destination)
        }
    }
}

// MARK: - Private

private extension EventsRouter {
    var requestContext: RequestContext {
        path.isEmpty ? .coldStart : .activeSession
    }

    func show(_ destination: EventsDestination) {
        switch showsSplitView {
        case true: select(destination)
        case false: push(destination)
        }
    }

    func select(_ destination: EventsDestination) {
        guard path != [destination] else { return }

        path = [destination]
    }

    func push(_ destination: EventsDestination) {
        guard path.last?.shows(sameScreenAs: destination) != true else { return }

        path.append(destination)
    }

    func present(_ destination: EventsDestination) {
        presentation = .init(destination: destination, style: view(for: destination).style)
    }

    func presentOverHome(_ destination: EventsDestination) {
        path = []
        showSheet(destination)
    }

    func showSheet(_ destination: EventsDestination) {
        switch destination {
        case .editor(let target): showEditor(for: target)
        default: present(destination)
        }
    }

    func isEditing(_ destination: EventsDestination) -> Bool {
        switch (presentation?.destination, destination) {
        case (.editor(.existing(let editedID)), .detail(let id, _)): editedID == id
        case (.editor(.existing(let editedID)), .editor(.existing(let id))): editedID == id
        default: false
        }
    }
}
