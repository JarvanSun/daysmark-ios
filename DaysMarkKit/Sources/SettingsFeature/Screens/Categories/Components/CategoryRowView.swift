//
//  CategoryRowView.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct CategoryRowView: View {
    let row: CategoriesContent.Row
    let onRename: () -> Void

    var body: some View {
        if row.isBuiltIn {
            Text(verbatim: row.name)
        } else {
            Button(action: onRename) {
                LabeledContent {
                    Image(style: DaysMarkImage.chevronForward)
                        .textStyle(DaysMarkColor.textTertiary, DaysMarkFont.disclosure)
                } label: {
                    Text(verbatim: row.name)
                        .foregroundStyle(DaysMarkColor.textPrimary.color)
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    List {
        ForEach(PreviewObjectPool().categoryRows) { row in
            CategoryRowView(row: row, onRename: {})
        }
    }
    .listStyle(.plain)
}
#endif
