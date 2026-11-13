//
//  ImportantDateLiveActivityWidget.swift
//  DaysMarkWidget
//
//  Created by Jiawen Sun on 2026/09/04.
//

import ActivityKit
import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI
import WidgetKit

struct ImportantDateLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ImportantDateActivityAttributes.self) { context in
            ImportantDateLockScreenView(context: context)
                .widgetURL(context.attributes.deepLink)
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(style: context.attributes.appearance.symbol)
                        .accessibilityHidden(true)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.presentedTitle)
                        .font(DaysMarkFont.widgetTitle)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ImportantDateActivityCountdown(state: context.state)
                        .font(DaysMarkFont.widgetTitle)
                        .monospacedDigit()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.target.label)

                        Spacer()

                        Text(context.state.targetDate, format: .dateTime.hour().minute())
                    }
                    .font(DaysMarkFont.widgetCaption)
                }
            } compactLeading: {
                Image(style: context.attributes.appearance.symbol)
                    .accessibilityHidden(true)
            } compactTrailing: {
                ImportantDateCompactCountdown(state: context.state)
            } minimal: {
                Image(style: context.attributes.appearance.symbol)
                    .accessibilityHidden(true)
            }
            .keylineTint(DaysMarkColor.tint.color)
        }
    }
}

private struct ImportantDateLockScreenView: View {
    @Environment(\.dimensions) private var dimensions

    let context: ActivityViewContext<ImportantDateActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.activitySpacing) {
            HStack(alignment: .firstTextBaseline) {
                Label {
                    Text(context.attributes.presentedTitle)
                } icon: {
                    Image(style: context.attributes.appearance.symbol)
                }
                .font(DaysMarkFont.widgetTitle)
                .lineLimit(2)

                Spacer(minLength: dimensions.spaceMedium)

                ImportantDateActivityCountdown(state: context.state)
                    .font(DaysMarkFont.activityCountdown)
                    .monospacedDigit()
                    .layoutPriority(1)
            }

            HStack {
                Text(context.state.target.label)

                Spacer()

                Text(context.state.targetDate, format: .dateTime.hour().minute())
            }
            .font(DaysMarkFont.widgetCaption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

private struct ImportantDateCompactCountdown: View {
    @Environment(\.dimensions) private var dimensions

    let state: ImportantDateActivityAttributes.ContentState

    var body: some View {
        ImportantDateActivityCountdown(state: state)
            .font(DaysMarkFont.widgetCaption)
            .monospacedDigit()
            .frame(maxWidth: dimensions.activityCountdownMaximumWidth)
    }
}

private struct ImportantDateActivityCountdown: View {
    let state: ImportantDateActivityAttributes.ContentState

    var body: some View {
        switch state.isTerminal {
        case true:
            Text("liveActivity.status.now")
        case false:
            Text(state.targetDate, style: .timer)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }
}

#if DEBUG
#Preview("Lock Screen", as: .content, using: PreviewObjectPool().activity) {
    ImportantDateLiveActivityWidget()
} contentStates: {
    for state in PreviewObjectPool().activityStates {
        state
    }
}
#endif
