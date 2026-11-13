//
//  AppRequestInbox.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Observation

@Observable
final class AppRequestInbox {
    private(set) var pendingRequest: AppRequest?

    func hold(_ request: AppRequest) {
        pendingRequest = request
    }

    func takePendingRequest() -> AppRequest? {
        defer { pendingRequest = nil }

        return pendingRequest
    }
}
