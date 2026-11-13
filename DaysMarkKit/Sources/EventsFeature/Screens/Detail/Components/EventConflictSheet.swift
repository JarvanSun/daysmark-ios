//
//  EventConflictSheet.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct EventConflictSheet: View {
    @Environment(\.dimensions) private var dimensions

    let versions: [EventConflictVersion]
    let onKeep: (EventConflictVersion.ID) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(versions) { row(for: $0) }
                } footer: {
                    Text("detail.conflict.footer", bundle: .module)
                }
            }
            .navigationTitle(Text("detail.conflict.title", bundle: .module))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        onCancel()
                    } label: {
                        Label(Text("detail.conflict.cancel", bundle: .module), symbol: .xmark)
                    }
                }
            }
        }
    }

    private func row(for version: EventConflictVersion) -> some View {
        VStack(alignment: .leading, spacing: dimensions.spaceCompact) {
            Text(verbatim: version.title)
                .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.headline)

            Text(verbatim: version.date)
                .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.supporting)

            Text(version.changedAt)
                .textStyle(DaysMarkColor.textTertiary, DaysMarkFont.footnote)

            Button(action: { onKeep(version.id) }) {
                Text("detail.conflict.keep", bundle: .module)
                    .frame(
                        minWidth: dimensions.minimumTapTarget,
                        minHeight: dimensions.minimumTapTarget
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.daysmark(.secondary))
        }
        .padding(.vertical, dimensions.spaceCompact)
    }
}

#if DEBUG
#Preview {
    EventConflictSheet(
        versions: PreviewObjectPool().conflictVersions,
        onKeep: { _ in },
        onCancel: {}
    )
}
#endif
