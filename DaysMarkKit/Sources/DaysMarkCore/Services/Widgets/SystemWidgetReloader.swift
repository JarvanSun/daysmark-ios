//
//  SystemWidgetReloader.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import WidgetKit

public protocol WidgetReloading: Sendable {
    func reloadAll()
}

public struct SystemWidgetReloader: WidgetReloading {
    public init() {}

    public func reloadAll() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
