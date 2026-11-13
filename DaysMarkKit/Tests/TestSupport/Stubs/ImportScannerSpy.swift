//
//  ImportScannerSpy.swift
//  TestSupport
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore

public final class ImportScannerSpy: ImportScanning {
    public var result: Result<[ImportResult], ImportError>

    public private(set) var scannedSources: [ImportScanSource] = []

    public init(result: Result<[ImportResult], ImportError> = .success([])) {
        self.result = result
    }

    public func scan(_ source: ImportScanSource) async throws(ImportError) -> [ImportResult] {
        scannedSources.append(source)
        return try result.get()
    }
}
