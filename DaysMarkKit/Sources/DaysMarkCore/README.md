# DaysMarkCore

Everything Daysmark does below the interface: what an important date is, how it is stored and
synced, and what follows a change. The app and the widget extension both link it; it imports no
SwiftUI or UIKit.

It is responsible for the SwiftData store, every write to that
store, date and repeat calculation, the phrase that says how far a date is, reminders, importing
from Contacts and Calendar, and the data the widget, the Live Activity and Spotlight read.

A ViewModel reads and writes stored data through a repository (`EventRepository`,
`CategoryRepository`). Its SwiftData implementation works on the main context, saves once and
asks `SystemSurfaceRefresher` to bring reminders, widgets, Spotlight and Live Activities up to
date; `changes()` tells a screen when to load again. A service is for what a repository cannot do:
a system framework or work across repositories, writing stored data through the repositories. The
app creates one instance of each. `Models/` never uses `Repositories/` or `Services/`.

| Folder | Contains | Start from |
|---|---|---|
| `Models/Event/`, `Models/History/` | the SwiftData models: an event and what belongs to it, its revisions | `CountdownEvent`, `EventCategory`, `EventRevision` |
| `Models/EventDrafts/` | an event while it is edited, its reminders, validation and preview | `EventDraft`, `ReminderDraft` |
| `Models/EventCalculation/` | occurrences, order and the computed focus, repetition, the content fingerprint | `EventOccurrenceResolver`, `EventSorter` |
| `Models/Dates/` | calendar dates, calendar systems, repeat rules, time of day | `EventDateSpecification`, `RepeatRule` |
| `Models/DayCount/` | day counts and the relative-time phrase every surface shows | `DayCountCalculator`, `DayCount`, `RelativeTimePhrase` |
| `Models/DeepLinks/`, `Models/Widgets/` | what a link, a notification or a command can ask the app to show; what a widget shows | `AppRequest`, `SettingsPage`, `WidgetContent` |
| `Persistence/` | the container, CloudKit setup, the local-source store, store changes, the repair run at launch and activation | `ModelContainerBuilder`, `StoreChanges`, `StoreRepair` |
| `Repositories/Events/` | reading events and the focus; saving drafts, deleting, the focus, revisions and conflicts, seeded and imported events | `EventRepository`, `SwiftDataEventRepository`, `EventError` |
| `Repositories/Categories/` | built-in and custom categories | `CategoryRepository`, `SwiftDataCategoryRepository` |
| `Services/Reminders/` | the reminder service; planning the 64 pending notifications in `Planning/`; system scheduling and permission in `Notifications/` | `ReminderService`, `ReminderPlanner` |
| `Services/Import/` | comparing scanned dates with stored events and applying an import; reading Contacts and Calendar in `Scanning/` | `ImportService`, `ImportResult` |
| `Services/Onboarding/` | ready-made events, whether onboarding shows | `OnboardingService`, `OnboardingSeed` |
| `Services/` (top) | what runs after a write; what Siri and Shortcuts ask (matching events and categories, candidates for a spoken create or edit); Spotlight | `SystemSurfaceRefresher`, `EventLookup`, `SpotlightIndexer` |
| `Services/Widgets/`, `Services/LiveActivities/` | what the widget reads, the Live Activity | `WidgetContentReader`, `ImportantDateActivityAttributes` |
| `Extensions/` | log categories, the digest of a string, calendar helpers, fixed UUIDs | `Logger(category:)` |
| `Resources/` | the module’s strings | `Localizable.xcstrings` |

Each repository and service throws one error type (`EventError`, `CategoryError`, `ImportError`,
`OnboardingError`); a feature maps it to the issue it shows. The identifiers installed copies
depend on are raw values of small enums beside the code that uses them (`StoreIdentifier`,
`WidgetKind`, `NotificationPayloadKey`), each pinned by a test.

Tests are in `DaysMarkKit/Tests/DaysMarkCoreTests/`, grouped by the same folders, with mocks in
`Mocks/` and the spies of its protocols shared through `TestSupport`:
`scripts/test.sh DaysMarkCore`.
