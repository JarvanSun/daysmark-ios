//
//  MomentRefreshModifier.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public protocol MomentRefreshing: AnyObject {
    func refresh()
}

struct MomentRefreshModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    let moment: MomentRefreshing
    let nextChange: Date?

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                moment.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
                moment.refresh()
            }
            .onChange(of: scenePhase) { _, phase in
                refreshWhenActive(phase)
            }
            .task(id: nextChange) {
                await refreshAtNextChange()
            }
    }

    private func refreshWhenActive(_ phase: ScenePhase) {
        guard phase == .active else { return }

        moment.refresh()
    }

    private func refreshAtNextChange() async {
        guard let nextChange else { return }

        let remaining = nextChange.timeIntervalSinceNow

        if remaining > 0 {
            try? await Task.sleep(for: .seconds(remaining))
        }

        guard !Task.isCancelled else { return }

        moment.refresh()
    }
}

extension View {
    public func refreshes(_ moment: MomentRefreshing, at nextChange: Date?) -> some View {
        modifier(MomentRefreshModifier(moment: moment, nextChange: nextChange))
    }
}
