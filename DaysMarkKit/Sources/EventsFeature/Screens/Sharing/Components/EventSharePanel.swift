//
//  EventSharePanel.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct EventSharePanel: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.locale) private var locale

    @State private var card: RenderedEventShareCard?

    let content: EventShareContent
    @Binding var includesCategory: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: dimensions.spaceXLarge) {
                switch card {
                case .some(let card):
                    Image(uiImage: card.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: dimensions.cornerRadiusLarge))
                        .accessibilityLabel(Text(verbatim: content.plainText))
                case nil: ProgressView()
                }

                Toggle(isOn: $includesCategory) {
                    Text("sharing.panel.includeCategory", bundle: .module)
                        .font(DaysMarkFont.rowTitle)
                }

                if let card {
                    shareLink(for: card)
                }
            }
            .padding(.horizontal, dimensions.pageMargin)
            .padding(.vertical, dimensions.spaceXLarge)
        }
        .task(id: content) {
            card = EventShareRenderer(locale: locale, cardWidth: dimensions.shareCardWidth)
                .render(content)
        }
    }

    private func shareLink(for card: RenderedEventShareCard) -> some View {
        ShareLink(
            item: card.transferable,
            preview: SharePreview(content.title, image: Image(uiImage: card.image))
        ) {
            Label(Text("sharing.panel.share", bundle: .module), symbol: .squareAndArrowUp)
                .font(DaysMarkFont.actionLabel)
                .frame(maxWidth: .infinity, minHeight: dimensions.minimumTapTarget)
        }
        .buttonStyle(.daysmark(.primary))
    }
}

#if DEBUG
#Preview {
    @Previewable @State var includesCategory = false

    NavigationStack {
        EventSharePanel(
            content: PreviewObjectPool().shareContents[0],
            includesCategory: $includesCategory
        )
    }
}
#endif
