//
//  EventDetailView.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct EventDetailView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dimensions) private var dimensions
    @Environment(\.eventZoomNamespace) private var zoomNamespace

    @Bindable var viewModel: EventDetailViewModel
    let zoomSource: EventZoomSource

    var body: some View {
        ZStack {
            if let event = viewModel.content.event {
                countdown(to: event)
            }
        }
        .zoomTransition(from: zoomSource, in: zoomNamespace)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { DetailToolbar(viewModel: viewModel) }
        .refreshes(viewModel.time, at: viewModel.content.nextChange)
        .onChange(of: viewModel.content.isDeleted) { viewModel.closeIfDeleted() }
        .task { await viewModel.observeStore() }
        .sheet(isPresented: $viewModel.isChoosingVersion) {
            EventConflictSheet(
                versions: viewModel.content.conflictVersions,
                onKeep: { viewModel.keep($0) },
                onCancel: { viewModel.cancelChoosingVersion() }
            )
        }
        .sensoryFeedback(.selection, trigger: viewModel.content.unit)
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() })
    }

    private func countdown(to event: EventItem) -> some View {
        VStack(spacing: 0) {
            DetailHeader(event: event)

            if viewModel.content.hasConflicts {
                conflictNotice
            }

            Spacer(minLength: dimensions.spaceXLarge)

            DetailCountButton(event: event, unit: viewModel.content.unit) {
                viewModel.showNextUnit()
            }

            if let target = viewModel.content.tickerTarget {
                LiveTicker(target: target)
                    .foregroundColor(DaysMarkColor.textSecondary)
                    .padding(.top, dimensions.spaceXLarge)
            }

            if viewModel.content.canSwitchUnit {
                Text("detail.count.switchUnitHint", bundle: .module)
                    .textStyle(DaysMarkColor.textTertiary, DaysMarkFont.footnote)
                    .padding(.top, dimensions.spaceMedium)
                    .accessibilityHidden(true)
            }

            Spacer(minLength: dimensions.spaceXLarge)

            shareButton
        }
        .padding(.horizontal, dimensions.spaceXLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(alignment: .top) {
            LinearGradient(
                colors: [event.tint.color.opacity(0.14), event.tint.color.opacity(0)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .overlay {
            if event.direction == .today {
                ConfettiView()
            }
        }
        .animation(
            DaysMarkMotion.directionChange.animation(reducingMotion: reduceMotion),
            value: event.direction
        )
    }

    private var conflictNotice: some View {
        Button {
            viewModel.chooseVersion()
        } label: {
            Label(Text("detail.conflict.notice", bundle: .module), symbol: .exclamationmarkTriangle)
                .font(DaysMarkFont.footnoteEmphasized)
                .frame(minHeight: dimensions.minimumTapTarget)
        }
        .buttonStyle(.daysmark(.caution))
        .padding(.top, dimensions.spaceMedium)
    }

    private var shareButton: some View {
        Button {
            viewModel.share()
        } label: {
            Label(Text("detail.actions.share", bundle: .module), symbol: .squareAndArrowUp)
                .font(DaysMarkFont.headline)
                .frame(
                    maxWidth: dimensions.primaryButtonMaximumWidth,
                    minHeight: dimensions.primaryButtonHeight
                )
        }
        .buttonStyle(.daysmark(.primary))
        .padding(.bottom, dimensions.spaceMedium)
    }
}

#if DEBUG
#Preview("Detail", arguments: EventsPreviewState.allCases) { state in
    let pool = PreviewObjectPool()
    let container = pool.modelContainer(state.contents)

    NavigationStack {
        EventDetailView(
            viewModel: pool.detailViewModel(in: container),
            zoomSource: EventZoomSource(eventID: pool.eventID, isFocus: false)
        )
    }
    .environment(\.locale, state.locale)
}
#endif
