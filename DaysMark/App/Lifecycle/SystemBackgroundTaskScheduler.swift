//
//  SystemBackgroundTaskScheduler.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import BackgroundTasks
import Foundation

struct SystemBackgroundTaskScheduler: BackgroundTaskScheduling {
    func submit(identifier: String, earliestBeginDate: Date) throws {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = earliestBeginDate

        try BGTaskScheduler.shared.submit(request)
    }
}
