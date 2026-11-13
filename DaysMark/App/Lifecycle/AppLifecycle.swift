//
//  AppLifecycle.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import OSLog
import SwiftUI

final class AppLifecycle {
    private let categories: CategoryRepository
    private let storeRepair: StoreRepair
    private let reminderService: ReminderService
    private let refresher: SystemSurfaceRefreshing
    private let backgroundRefresh: BackgroundRefresh

    private var importObserver: StoreImportObserver?

    init(
        categories: CategoryRepository,
        storeRepair: StoreRepair,
        reminderService: ReminderService,
        refresher: SystemSurfaceRefreshing,
        backgroundRefresh: BackgroundRefresh
    ) {
        self.categories = categories
        self.storeRepair = storeRepair
        self.reminderService = reminderService
        self.refresher = refresher
        self.backgroundRefresh = backgroundRefresh
    }

    func launch() {
        backgroundRefresh.register()

        importObserver = StoreImportObserver(notificationCenter: .default) { [weak self] in
            self?.repairAndRefresh()
        }
    }

    func start() async {
        repairAndRefresh()

        await reminderService.registerCategories()
    }

    func sceneChanged(to phase: ScenePhase) {
        guard phase == .active else { return }

        repairAndRefresh()
        backgroundRefresh.scheduleNext()
    }

    private func repairAndRefresh() {
        repairStore()
        refresher.refresh()
    }

    private func repairStore() {
        do {
            try categories.seedBuiltInCategories()
            try storeRepair.run()
        } catch {
            Logger(category: .data).error(
                "Data repair failed: \(String(describing: error), privacy: .public)"
            )
        }
    }
}
