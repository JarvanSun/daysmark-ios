//
//  EventsRouterSpy.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

@testable import EventsFeature

final class EventsRouterSpy: EventsRouting {
    enum Call: Equatable {
        case home
        case detail(UUID)
        case detailFromFocus(UUID)
        case settings(SettingsPage)
        case editor(EditorTarget)
        case specialNodes
        case sharing(UUID)
        case requestedDetail(UUID)
        case requestedSettings(SettingsPage)
        case closeDetail(UUID)
        case dismissSheet
    }

    var isPresentingSheet = false

    private(set) var calls: [Call] = []

    func showHome() {
        calls.append(.home)
    }

    func showDetail(for id: CountdownEvent.ID) {
        calls.append(.detail(id))
    }

    func showDetailFromFocus(for id: CountdownEvent.ID) {
        calls.append(.detailFromFocus(id))
    }

    func showSettings(_ page: SettingsPage) {
        calls.append(.settings(page))
    }

    func showEditor(for target: EditorTarget) {
        calls.append(.editor(target))
    }

    func showSpecialNodes() {
        calls.append(.specialNodes)
    }

    func showSharing(for id: CountdownEvent.ID) {
        calls.append(.sharing(id))
    }

    func showRequestedDetail(for id: CountdownEvent.ID) {
        calls.append(.requestedDetail(id))
    }

    func showRequestedSettings(_ page: SettingsPage) {
        calls.append(.requestedSettings(page))
    }

    func closeDetail(for id: CountdownEvent.ID) {
        calls.append(.closeDetail(id))
    }

    func dismissSheet() {
        calls.append(.dismissSheet)
    }
}
