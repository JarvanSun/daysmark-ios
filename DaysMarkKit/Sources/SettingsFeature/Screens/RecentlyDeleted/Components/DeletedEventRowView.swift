//
//  DeletedEventRowView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct DeletedEventRowView: View {
    @Environment(\.dimensions) private var dimensions

    let row: RecentlyDeletedContent.Row

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.rowLineSpacing) {
            Text(verbatim: row.title)
                .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.eventTitle)
                .lineLimit(2)

            Text(
                "settings.recentlyDeleted.row.deletedAt \(row.deletedAt, format: .relative(presentation: .named))",
                bundle: .module
            )
            .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.rowSecondary)
        }
        .padding(.vertical, dimensions.spaceSmall)
    }
}

#if DEBUG
#Preview {
    List {
        ForEach(PreviewObjectPool().deletedEventRows) { row in
            DeletedEventRowView(row: row)
                .listRowBackground(row.background)
        }
    }
    .listStyle(.plain)
}
#endif
