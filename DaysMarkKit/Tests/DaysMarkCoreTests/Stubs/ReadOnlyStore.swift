//
//  ReadOnlyStore.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import SwiftData

@testable import DaysMarkCore

final class ReadOnlyStore {
    let container: ModelContainer

    private let directory: URL

    @MainActor
    init(seededWith events: [CountdownEvent]) throws {
        directory = FileManager.default.temporaryDirectory
            .appending(path: "ReadOnlyStore-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appending(path: "Fixture.store")

        do {
            let writer = try ModelContainer(
                for: Schema.mockCurrent,
                configurations: [ModelConfiguration.mockOnDisk(at: url)]
            )

            for event in events {
                writer.mainContext.insert(event)
            }

            try writer.mainContext.save()
        }

        container = try ModelContainer(
            for: Schema.mockCurrent,
            configurations: [ModelConfiguration.mockReadOnly(at: url)]
        )
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }
}
