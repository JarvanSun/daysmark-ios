//
//  FilterBar.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct FilterBar: View {
    @Environment(\.dimensions) private var dimensions

    let categories: [HomeContent.Category]
    let onSelect: (EventCategory.ID?) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: dimensions.spaceMedium) {
                ForEach(categories) { category in
                    Button {
                        onSelect(category.id)
                    } label: {
                        title(of: category)
                            .textStyle(
                                category.isSelected ? DaysMarkColor.tint : .textSecondary,
                                category.isSelected
                                    ? DaysMarkFont.filterLabelSelected : .filterLabel
                            )
                            .frame(
                                minWidth: dimensions.minimumTapTarget,
                                minHeight: dimensions.minimumTapTarget
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(category.isSelected ? .isSelected : [])
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private func title(of category: HomeContent.Category) -> Text {
        switch category.name {
        case .some(let name): Text(verbatim: name)
        case nil: Text("home.filter.category.all", bundle: .module)
        }
    }
}
