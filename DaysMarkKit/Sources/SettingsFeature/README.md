# SettingsFeature

Everything behind Home's Settings entry: notifications, categories, importing from Contacts and
Calendar, Recently Deleted, how to add widgets, Siri and Shortcuts, and About. It is pushed onto
the stack Home owns, so it brings no navigation stack of its own.

It is responsible for what each of those screens shows and decides. Categories and Recently
Deleted load their records from `CategoryRepository` and `EventRepository` and ask them to rename,
reorder and delete categories and to restore or permanently delete events; Import and
Notifications call DaysMarkCore's services to scan and apply an import and to ask for notification
permission. It never touches SwiftData itself.

Start from `SettingsHostView`, the only view another module can show, given a `SettingsPage` to
open on, and `SettingsDependencies`, what the App passes in through `EventsDependencies`.
EventsFeature pushes it; Settings imports no other feature.

| Folder | Contains | Start from |
|---|---|---|
| `Navigation/` | the dependencies, every screen Settings can show, the router | `SettingsDestination`, `SettingsRouter` |
| `Screens/Settings/` | the root list; the widget instructions, Siri and Shortcuts and About, which have no ViewModel | `SettingsView` |
| `Screens/Categories/` | the category list and, in `Editor/`, the sheet that names a category | `CategoriesViewModel` |
| `Screens/Import/` | choosing a source, reviewing what was found, importing it | `ImportViewModel` |
| `Screens/Notifications/` | the permission and the default reminder time | `NotificationsViewModel` |
| `Screens/RecentlyDeleted/` | restoring and permanently deleting, one event or a selection | `RecentlyDeletedViewModel` |
| `UserInterface/` | what only Settings reuses: the link to the system Settings, how import decisions and the notification permission read | `SystemSettingsLink` |
| `Resources/` | the feature's strings in five languages | `Localizable.xcstrings` |
| `Preview Content/` | data and stand-ins for every preview | `PreviewObjectPool` |

Tests are in `DaysMarkKit/Tests/SettingsFeatureTests/`, grouped by the same folders:
`scripts/test.sh SettingsFeature`.
