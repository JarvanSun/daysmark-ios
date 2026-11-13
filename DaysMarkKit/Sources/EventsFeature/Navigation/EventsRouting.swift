//
//  EventsRouting.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Foundation

protocol EventsRouting: AnyObject {
    var isPresentingSheet: Bool { get }

    func showHome()
    func showDetail(for id: CountdownEvent.ID)
    func showDetailFromFocus(for id: CountdownEvent.ID)
    func showSettings(_ page: SettingsPage)
    func showEditor(for target: EditorTarget)
    func showSpecialNodes()
    func showSharing(for id: CountdownEvent.ID)
    func showRequestedDetail(for id: CountdownEvent.ID)
    func showRequestedSettings(_ page: SettingsPage)
    func closeDetail(for id: CountdownEvent.ID)
    func dismissSheet()
}
