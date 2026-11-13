//
//  BundleDescriptionExtensions.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension LocalizedStringResource.BundleDescription {
    static var module: Self {
        .atURL(Bundle.module.bundleURL)
    }
}
