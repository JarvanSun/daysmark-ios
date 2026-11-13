//
//  WidgetDisplayRows.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

@testable import DaysMarkCore

extension WidgetDisplay {
    var rows: [WidgetRow] {
        switch self {
        case .event(let row): [row]
        case .list(let rows): rows
        case .unavailable: []
        }
    }

    var isList: Bool {
        switch self {
        case .list: true
        case .event, .unavailable: false
        }
    }
}
