//
//  HomeEmptyView.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/09/02.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct HomeEmptyView: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.colorScheme) private var colorScheme

    let placeholder: HomeContent.Placeholder
    let onAdd: () -> Void
    let onResetFilters: () -> Void

    var body: some View {
        Group {
            switch placeholder {
            case .noEvents: noEvents
            case .noMatches: noMatches
            case .noSearchResults(let text):
                ContentUnavailableView.search(text: text).padding(.top, dimensions.spaceXXLarge)
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.horizontal, dimensions.pageMargin)
        .listRowInsets(.vertical, 0)
        .listRowSeparator(.hidden)
    }

    private var noEvents: some View {
        VStack(spacing: dimensions.spaceXLarge) {
            Image(colorScheme == .dark ? .homeFirstDateDark : .homeFirstDate)
                .resizable()
                .scaledToFit()
                .blendMode(colorScheme == .dark ? .screen : .multiply)
                .frame(maxWidth: dimensions.emptyArtworkMaximumWidth)
                .accessibilityHidden(true)

            message(
                title: Text("home.empty.title", bundle: .module),
                detail: Text("home.empty.description", bundle: .module),
                titleFont: .placeholderTitle,
                spacing: dimensions.placeholderMessageSpacing
            )

            Button(action: onAdd) {
                Text("home.empty.create", bundle: .module)
                    .font(DaysMarkFont.buttonLabel)
                    .padding(.horizontal, dimensions.spaceMedium)
                    .frame(minHeight: dimensions.minimumTapTarget)
            }
            .buttonStyle(.daysmark(.primary))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, dimensions.placeholderTopInset)
        .padding(.bottom, dimensions.spaceXXLarge)
    }

    private func message(
        title: Text,
        detail: Text,
        titleFont: DaysMarkFont,
        spacing: CGFloat
    ) -> some View {
        VStack(spacing: spacing) {
            title
                .textStyle(DaysMarkColor.textPrimary, titleFont)
                .accessibilityAddTraits(.isHeader)

            detail.textStyle(DaysMarkColor.textSecondary, DaysMarkFont.supporting)
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var noMatches: some View {
        VStack(spacing: dimensions.spaceMedium) {
            leaves
                .frame(
                    width: dimensions.filteredArtworkWidth,
                    height: dimensions.filteredArtworkHeight
                )
                .accessibilityHidden(true)

            message(
                title: Text("home.filter.empty.title", bundle: .module),
                detail: Text("home.filter.empty.description", bundle: .module),
                titleFont: .noticeTitle,
                spacing: dimensions.spaceSmall
            )
            .accessibilityElement(children: .combine)

            Button(action: onResetFilters) {
                Text("home.filter.reset", bundle: .module)
                    .font(DaysMarkFont.linkLabel)
                    .frame(
                        minWidth: dimensions.minimumTapTarget,
                        minHeight: dimensions.minimumTapTarget
                    )
                    .contentShape(Rectangle())
            }
            .buttonStyle(.daysmark(.row))
            .foregroundColor(DaysMarkColor.tint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, dimensions.spaceXXLarge)
    }

    @ViewBuilder
    private var leaves: some View {
        switch colorScheme {
        case .dark:
            Image(.homeEmptyPaperLeaves)
                .resizable()
                .scaledToFit()
                .saturation(0)
                .colorInvert()
                .colorMultiply(DaysMarkColor.tint.color)
                .blendMode(.screen)
        default:
            Image(.homeEmptyPaperLeaves)
                .resizable()
                .scaledToFit()
                .saturation(0.8)
                .blendMode(.multiply)
        }
    }
}

#if DEBUG
#Preview("No events") {
    List {
        HomeEmptyView(placeholder: .noEvents, onAdd: {}, onResetFilters: {})
    }
    .listStyle(.plain)
    .listSectionSeparator(.hidden)
    .scrollContentBackground(.hidden)
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}

#Preview("No matches") {
    List {
        HomeEmptyView(placeholder: .noMatches, onAdd: {}, onResetFilters: {})
    }
    .listStyle(.plain)
    .listSectionSeparator(.hidden)
    .scrollContentBackground(.hidden)
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
