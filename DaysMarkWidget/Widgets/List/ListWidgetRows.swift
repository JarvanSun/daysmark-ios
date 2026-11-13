//
//  ListWidgetRows.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SwiftUI
import WidgetKit

struct ListWidgetRows: View {
    @Environment(\.widgetFamily) private var family

    let rows: [WidgetRow]

    var body: some View {
        ViewThatFits(in: .vertical) {
            ForEach((1...rowLimit).reversed(), id: \.self) { count in
                stack(of: rows.prefix(count))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var rowLimit: Int {
        switch family {
        case .systemMedium: 3
        default: 6
        }
    }

    private func stack(of rows: ArraySlice<WidgetRow>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                if index > 0 {
                    Divider()
                }

                if let link = row.link.url {
                    Link(destination: link) {
                        ListWidgetRow(row: row)
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview("Medium", as: .systemMedium) {
    ListWidget()
} timeline: {
    for entry in PreviewObjectPool().listEntries {
        entry
    }
}
#endif
