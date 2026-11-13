//
//  ImportantDateAppShortcuts.swift
//  Daysmark
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AppIntents

struct ImportantDateAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FindImportantDatesIntent(),
            phrases: [
                "Find important dates in \(.applicationName)",
                "What's coming up in \(.applicationName)",
            ],
            shortTitle: "shortcut.find.title",
            systemImageName: "calendar.badge.clock"
        )
        AppShortcut(
            intent: GetImportantDateDistanceIntent(),
            phrases: ["Get time for \(\.$event) in \(.applicationName)"],
            shortTitle: "shortcut.distance.title",
            systemImageName: "clock"
        )
        AppShortcut(
            intent: CreateImportantDateIntent(),
            phrases: ["Create an important date in \(.applicationName)"],
            shortTitle: "shortcut.create.title",
            systemImageName: "plus"
        )
        AppShortcut(
            intent: EditImportantDateIntent(),
            phrases: ["Edit an important date in \(.applicationName)"],
            shortTitle: "shortcut.edit.title",
            systemImageName: "pencil"
        )
    }

    static let shortcutTileColor: ShortcutTileColor = .purple
}
