//
//  HomeHeader.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/13.
//

import DesignSystem
import SunUserInterface
import SwiftUI

struct HomeHeader: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.eventZoomNamespace) private var zoomNamespace

    let viewModel: HomeViewModel

    var body: some View {
        if let pinned = viewModel.content.pinned {
            Button {
                viewModel.openPinned(pinned.id)
            } label: {
                PinnedEventCard(event: pinned.event)
            }
            .buttonStyle(.daysmark(.row))
            .disabled(viewModel.isSelecting)
            .zoomSource(id: EventZoomSource(eventID: pinned.id, isFocus: true), in: zoomNamespace)
            .padding(.top, dimensions.spaceSmall)
            .padding(.bottom, dimensions.spaceXLarge)
            .listRowBackground(Color.clear)
            .listRowInsets(.horizontal, dimensions.pageMargin)
            .listRowInsets(.vertical, 0)
            .listRowSeparator(.hidden)
        }

        LandscapeIllustration(markers: viewModel.content.horizon)
            .padding(.bottom, dimensions.spaceXLarge)
            .listRowBackground(Color.clear)
            .listRowInsets(.horizontal, dimensions.pageMargin)
            .listRowInsets(.vertical, 0)
            .listRowSeparator(.hidden)

        FilterBar(
            categories: viewModel.content.categories,
            onSelect: { viewModel.selectCategory($0) }
        )
        .padding(.bottom, dimensions.spaceMedium)
        .listRowBackground(Color.clear)
        .listRowInsets(.horizontal, dimensions.pageMargin)
        .listRowInsets(.vertical, 0)
        .listRowSeparator(.hidden)
    }
}
