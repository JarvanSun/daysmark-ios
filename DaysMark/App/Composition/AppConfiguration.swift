//
//  AppConfiguration.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/10/07.
//

import Foundation

struct AppConfiguration {
    let bundle: Bundle

    var version: String {
        bundleValue(for: "CFBundleShortVersionString")
    }

    var build: String {
        bundleValue(for: "CFBundleVersion")
    }

    private func bundleValue(for key: String) -> String {
        bundle.infoDictionary?[key] as? String ?? "–"
    }
}
