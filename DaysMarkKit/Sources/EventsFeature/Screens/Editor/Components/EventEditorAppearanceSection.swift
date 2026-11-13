//
//  EventEditorAppearanceSection.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct EventEditorAppearanceSection: View {
    @Environment(\.dimensions) private var dimensions

    @Binding var selection: String

    var body: some View {
        Section {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: columnCount),
                spacing: dimensions.spaceSmall
            ) {
                ForEach(EventAppearance.allCases.filter(\.isSelectable)) { appearance in
                    Button {
                        selection = appearance.rawValue
                    } label: {
                        EventIcon(appearance, size: dimensions.appearanceChoiceSize)
                            .frame(maxWidth: .infinity, minHeight: dimensions.minimumTapTarget)
                            .background(
                                selection == appearance.rawValue
                                    ? DaysMarkColor.tintSoft.color : Color.clear,
                                in: .rect(cornerRadius: dimensions.cornerRadiusLarge)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(verbatim: appearance.label ?? appearance.rawValue))
                    .accessibilityAddTraits(selection == appearance.rawValue ? .isSelected : [])
                }
            }
        } header: {
            Text("editor.appearance.title", bundle: .module)
        }
    }

    private var columnCount: Int { 5 }
}
