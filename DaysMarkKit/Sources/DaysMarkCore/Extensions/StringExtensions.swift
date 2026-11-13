//
//  StringExtensions.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CryptoKit
import Foundation

extension String {
    var sha256Digest: String {
        SHA256.hash(data: Data(utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
