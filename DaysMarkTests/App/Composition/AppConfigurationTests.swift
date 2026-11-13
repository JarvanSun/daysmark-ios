//
//  AppConfigurationTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import DaysMark

struct AppConfigurationTests {
    @Test func versionAndBuildThenComeFromTheBundle() {
        // Given / When
        let configuration = AppConfiguration(bundle: .main)

        // Then
        #expect(!configuration.version.isEmpty)
        #expect(!configuration.build.isEmpty)
    }
}
