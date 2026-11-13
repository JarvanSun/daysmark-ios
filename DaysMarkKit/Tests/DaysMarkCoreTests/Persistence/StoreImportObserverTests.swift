//
//  StoreImportObserverTests.swift
//  DaysMarkCoreTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreData
import Foundation
import Testing

@testable import DaysMarkCore

@MainActor
struct StoreImportObserverTests {
    @Test func noteImportWhenCalledRepeatedlyThenRunsOnce() async {
        // Given
        let (imports, continuation) = AsyncStream.makeStream(of: Void.self)
        var passes = 0
        let observer = StoreImportObserver(notificationCenter: NotificationCenter()) {
            passes += 1
            continuation.yield()
        }

        // When
        observer.noteImport()
        observer.noteImport()
        observer.noteImport()

        for await _ in imports {
            break
        }

        // Then
        #expect(passes == 1)
    }
}
