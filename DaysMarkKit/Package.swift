// swift-tools-version: 6.2
//
//  Package.swift
//  DaysMarkKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import PackageDescription

let mainActorByDefault: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

let package = Package(
    name: "DaysMarkKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "DaysMarkCore", targets: ["DaysMarkCore"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "EventsFeature", targets: ["EventsFeature"]),
        .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
        .library(name: "OnboardingFeature", targets: ["OnboardingFeature"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JarvanSun/SunKit.git", .upToNextMinor(from: "0.2.2"))
    ],
    targets: [
        .target(
            name: "DaysMarkCore",
            exclude: ["README.md"],
            resources: [.process("Resources")],
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [.product(name: "SunUserInterface", package: "SunKit")],
            exclude: ["README.md"],
            resources: [.process("Resources")],
            swiftSettings: mainActorByDefault
        ),
        .target(
            name: "EventsFeature",
            dependencies: [
                "DaysMarkCore",
                "DesignSystem",
                "SettingsFeature",
                .product(name: "SunUserInterface", package: "SunKit"),
            ],
            exclude: ["README.md"],
            resources: [.process("Resources")],
            swiftSettings: mainActorByDefault
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                "DaysMarkCore",
                "DesignSystem",
                .product(name: "SunUserInterface", package: "SunKit"),
            ],
            exclude: ["README.md"],
            resources: [.process("Resources")],
            swiftSettings: mainActorByDefault
        ),
        .target(
            name: "OnboardingFeature",
            dependencies: [
                "DaysMarkCore",
                "DesignSystem",
                .product(name: "SunUserInterface", package: "SunKit"),
            ],
            exclude: ["README.md"],
            resources: [.process("Resources")],
            swiftSettings: mainActorByDefault
        ),
        .target(
            name: "TestSupport",
            dependencies: ["DaysMarkCore"],
            path: "Tests/TestSupport",
            swiftSettings: mainActorByDefault
        ),
        .testTarget(
            name: "DaysMarkCoreTests",
            dependencies: ["DaysMarkCore", "TestSupport"],
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"],
            swiftSettings: mainActorByDefault
        ),
        .testTarget(
            name: "EventsFeatureTests",
            dependencies: ["EventsFeature", "TestSupport"],
            swiftSettings: mainActorByDefault
        ),
        .testTarget(
            name: "SettingsFeatureTests",
            dependencies: ["SettingsFeature", "TestSupport"],
            swiftSettings: mainActorByDefault
        ),
        .testTarget(
            name: "OnboardingFeatureTests",
            dependencies: ["OnboardingFeature", "TestSupport"],
            swiftSettings: mainActorByDefault
        ),
    ],
    swiftLanguageModes: [.v6]
)
