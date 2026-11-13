//
//  BackgroundTaskScheduling.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

protocol BackgroundTaskScheduling: Sendable {
    func submit(identifier: String, earliestBeginDate: Date) throws
}
