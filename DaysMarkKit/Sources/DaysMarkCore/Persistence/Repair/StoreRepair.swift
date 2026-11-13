//
//  StoreRepair.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@MainActor
public struct StoreRepair {
    private let container: ModelContainer
    private let localSources: ModelContainer?
    private let now: () -> Date

    public init(container: ModelContainer, localSources: ModelContainer?, now: @escaping () -> Date)
    {
        self.container = container
        self.localSources = localSources
        self.now = now
    }

    public func run() throws(EventError) {
        do {
            try EventRepair(context: container.mainContext).repair(now: now())
            try cleanUpLocalSources()
        } catch {
            throw EventError(error)
        }
    }

    private func cleanUpLocalSources() throws {
        guard let localSources else { return }

        let cleanup = LocalSourceCleanup(context: localSources.mainContext)
        try EventLifecycle(context: container.mainContext).purgeExpired(
            cleaningUp: cleanup,
            now: now()
        )
        try cleanup.finishInterrupted(comparingWith: container.mainContext)
    }
}
