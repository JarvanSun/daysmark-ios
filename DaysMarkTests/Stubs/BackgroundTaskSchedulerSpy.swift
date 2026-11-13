//
//  BackgroundTaskSchedulerSpy.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Synchronization

@testable import DaysMark

final class BackgroundTaskSchedulerSpy: BackgroundTaskScheduling {
    var submissions: [Submission] { recorded.withLock(\.self) }

    private let recorded = Mutex<[Submission]>([])
    private let failure: Error?

    init(failure: Error? = nil) {
        self.failure = failure
    }

    func submit(identifier: String, earliestBeginDate: Date) throws {
        if let failure {
            throw failure
        }

        recorded.withLock {
            $0.append(Submission(identifier: identifier, earliestBeginDate: earliestBeginDate))
        }
    }
}

extension BackgroundTaskSchedulerSpy {
    struct Submission: Equatable {
        let identifier: String
        let earliestBeginDate: Date
    }
}
