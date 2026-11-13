# Persistence

All stored data lives in DaysMarkCore: SwiftData models in one store inside the App Group, synced
by the system through the user's private CloudKit database. Features see models to read, drafts to
edit, and one repository per kind of stored record. A ViewModel calls a repository, the repository
writes through the main `ModelContext`, and nothing stands in between
([architecture.md](architecture.md#no-needless-indirection)).

| Folder of `DaysMarkCore/` | Owns |
|---|---|
| `Models/` | The `@Model` classes (`Event/`, `History/`), drafts (`EventDrafts/`), and the plain values and calculation every surface shares (`EventCalculation/`, `Dates/`, `DayCount/`, `DeepLinks/`, `Widgets/`) |
| `Persistence/` | The container, `StoreChanges`, `StoreImportObserver`, the CloudKit schema initializer, `Repair/` |
| `Repositories/` | Every read and write of stored data: `Events/` and `Categories/` |
| `Services/` | Work with a system framework or across repositories: reminders, import, onboarding, Siri lookup, widgets, Live Activities, Spotlight |

## Public and internal

- Public: values and their calculators, the `@Model` classes with read access, drafts and domain
  errors, the repository and service protocols with their implementations, the container builder,
  `StoreChanges` and `StoreRepair`.
- Internal: the steps a repository or service calls (`EventDraftWriter`, `EventRevisionWriter`,
  `EventLifecycle`, `ReminderReconciler`), repair steps, store identifiers.
- A model's stored properties are `public private(set)`: other modules read them and cannot write
  them. Tests reach internal parts with `@testable import DaysMarkCore`.

## The container

`ModelContainerBuilder(role:storage:)` is the only code that creates a `ModelContainer`.

| `StoreRole` | Saves | CloudKit | Used by |
|---|---|---|---|
| `.app` | Yes | The private database of `iCloud.com.example.daysmark` | The App |
| `.widget` | No | `.none` | The widget extension |

`StoreStorage` is `.appGroup` (`CountdownDays.store` in the App Group container) or `.inMemory`
(tests and previews, always without CloudKit).

- The CloudKit database is always stated, `.private(…)` or `.none`.
- When the App Group container is unavailable, the builder logs it and stores in the default
  location without CloudKit; only the widget is empty.
- The App creates the container once, in `AppDependencies`. If that fails the app cannot run: it
  is the one `fatalError` in the codebase.
- Identifiers of imported contacts and calendar events are device-local. They live in a second
  store, `CountdownDaysLocalSources`, outside the App Group and without CloudKit.

## Models

| Model | Holds |
|---|---|
| `CountdownEvent` | One important date: title, calendar components of start and end, repeat, category ID, appearance, deletion state, the current revision ID |
| `EventCategory` | A built-in or custom category: name, sort order, deletion state |
| `ReminderRule`, `SpecialReminderNode` | An event's ordinary reminders and special nodes |
| `EventRevision` | An immutable snapshot of an event's editable content |
| `FocusSelection`, `FocusSelectionRevision` | The one focus and its history |
| `PermanentDeletionMarker` | The ID of an event that must never come back |

- An event stores calendar components (era, year, month, day, leap month, optional hour and
  minute), never a `Date` or a time zone. `EventDateSpecification` is their typed form.
- Every record has its own `UUID`. Records refer to each other by ID; a missing target is
  tolerated, because CloudKit delivers records in any order.

## CloudKit constraints

- No `@Attribute(.unique)`, no `#Unique`, no non-optional relationship, no `.deny` delete rule.
- Every stored property has a default or is optional.
- Uniqueness the product needs (one focus, one of each built-in category) is kept by the
  repository and restored by repair, deterministically: every device picks the same winner.
- The schema is one plain `Schema` of the current models (`ModelContainerBuilder.syncedModels`),
  with no versions and no migration plan. A new field is optional or has a default.
- `CloudKitSchemaInitializer` is the only production file compiled under `#if DEBUG`: a Debug
  build started with its launch argument uploads the development schema and exits.

## Reads and writes

`Repositories/Events/EventRepository.swift`, shortened:

```swift
@MainActor
public protocol EventRepository: AnyObject, Sendable {
    func changes() -> AsyncStream<Void>

    func events() throws(EventError) -> [CountdownEvent]

    @discardableResult
    func save(_ draft: EventDraft, replacing id: CountdownEvent.ID?) throws(EventError)
        -> CountdownEvent.ID

    func delete(eventID: UUID) throws(EventError)

    func setFocus(eventID: UUID?) throws(EventError)

    func resolveConflict(eventID: UUID, keeping versionID: UUID) throws(EventError)
}
```

- Reads return the models; every caller treats them as read-only. `changes()` yields after every
  `ModelContext` save and every finished CloudKit import (`StoreChanges`), so a ViewModel reloads
  instead of listening to SwiftData itself.
- The SwiftData implementation is the only writer of its models. It works on the container's main
  context.
- A write validates, changes models, saves once, then calls `SystemSurfaceRefresher.refresh()`
  ([system-surfaces.md](system-surfaces.md#after-a-write)). A failed save rolls back and throws
  the domain error.
- A write that touches several records (deleting a category and moving its events) is one method
  and one save. Writes take IDs and values, never a model another caller holds.
- Nothing outside DaysMarkCore calls `ModelContext.insert`, `delete` or `save`.
- A service that changes stored data writes through the repositories: `ImportService` calls
  `EventRepository.write(_:)`, `OnboardingService` calls `seed(_:)`.

## Drafts

Editing never touches a stored record until the user saves.

- `EventDraft` is a value made from an event (`EventDraft(_ event:)`) or for a new one
  (`EventDraft(startingOn:categoryID:)`). It has no hidden defaults: the day and the category are
  passed in.
- The editor's ViewModel changes only its draft. Cancel throws the draft away.
- Validation is the draft's: a title that is not blank, a date that exists in its calendar, an end
  not before the start. `EventRepository.save` validates again and throws
  `EventError.invalidDraft`.
- `baseRevisionID` is the revision the draft was made from; saving appends a revision whose parent
  it is, so a concurrent edit is noticed instead of overwritten.

## Revisions and conflicts

- Every change to an event's content appends an immutable `EventRevision` (a snapshot, the parent
  revision ID, the time, the device), then updates the event's fields to match. The event's
  fields are a read copy of its current revision.
- Two revisions with the same parent are a conflict. Both are kept; nothing picks a winner by
  timestamp. Event detail lists the versions (`conflictVersions(of:)`); keeping one appends a
  resolution revision.
- Deleting and restoring are revisions too.

## Deleting

| Step | Stored as | Effect |
|---|---|---|
| Delete | `deletedAt` | Gone from Home, widgets, reminders, Spotlight; in Recently Deleted for 30 days |
| Restore | A revision; `deletedAt` cleared | Back everywhere |
| Delete permanently | `permanentDeletionRequestedAt` and a revision | Gone on every device |
| Physical removal | Records deleted, `PermanentDeletionMarker` kept | After the deletion has been synced for 30 days |

The marker outranks the record: an old copy that arrives later is deleted again, and seeded events
are not created again.

## Focus, categories and imports

- The focus is one `FocusSelection` pointing at an event ID; without one, `EventSorter` computes
  it.
- The three built-in categories have fixed IDs (`BuiltInCategory`) and are seeded idempotently.
- An imported event keeps only where it came from (`ImportSourceKind`) and a fingerprint of the
  imported snapshot; raw contact and calendar identifiers stay in the device-local store.

## Repair

`StoreRepair.run()` (in `Persistence/Repair/`) runs when the app becomes active and after every
finished CloudKit import, right after the built-in categories are seeded. It converges duplicates,
applies deletion markers, clears a focus on a deleted event, removes expired deletions and
finishes local cleanup. Every step is idempotent.

`StoreImportObserver` listens only to finished, successful CloudKit import events and tells
`AppLifecycle` to repair and refresh.

## The app writes, the widget reads

The widget extension opens the same store with `StoreRole.widget`: it cannot save and does not
talk to CloudKit. It calls only `Services/Widgets/`, the values in `Models/`, and the Live
Activity attributes; it never creates a repository or service.

## Deterministic dates

Every number of days, every next occurrence and every reminder time comes from the same code.

- `EventOccurrenceResolver` answers which occurrence counts at a moment; `DayCountCalculator`
  turns it into a `DayCount` (direction, amount, unit); `EventSorter` orders events and picks the
  computed focus. Every surface calls these and nothing else.
- Their inputs are explicit: the event's components, `now`, a `Calendar` and a `TimeZone`. No
  calculator reads `Date()`, `Calendar.current`, `TimeZone.current` or `Locale.current`.
- Nothing subtracts two `Date`s to count days. Each moment is computed from the event again.
- **Strict construction.** A date is built from components in the event's calendar, converted
  back, and compared field by field. Any difference means the date does not exist: creation
  rejects it and repetition skips it.
