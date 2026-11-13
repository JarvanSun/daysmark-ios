# Swift Style

Code reads top to bottom like prose: every name says what a thing is, every function does one
thing, and nothing needs a comment.

## Formatting

Layout a tool can decide is fixed in `.swift-format` and applied by `scripts/format.sh`.

- 4-space indentation, 100 columns. A line that fits is not wrapped.
- A comma-separated list fits on one line, or every element goes on its own line. Never mix.
- One blank line between declaration groups and between sibling views
  ([views.md](views.md#siblings)). Never two blank lines in a row, and none before a closing
  brace.
- In a function, each step is its own paragraph. A `let` stays with the statement right after it
  that uses it. A block (`if`, `guard`, `for`, `switch`, `do`) has one blank line before and after
  it, unless it is the first or last statement of its scope.

  ```swift
  func delete(_ event: EventItem) {
      guard event.canBeDeleted else { return }

      if event.isFocused {
          clearFocus()
      }

      remove(event)
  }
  ```

- `#if DEBUG` blocks are not indented.

## Files

- Every Swift file starts with the Xcode header, then its imports.
- One concept per file, named after its main type. A type that belongs to that concept (its kind
  enum, its small values, its display) lives in the same file.
- An extension of a type from another module goes in `<Type>Extensions.swift`
  (`CalendarExtensions.swift`), never `Calendar+Days.swift`. Another extension of our own type in
  its own file is named after what it adds (`EventDraftValidation.swift`).
- Nothing lives at file level except types and their extensions; a helper is a `private` member
  of the type that uses it.

## Naming

| Kind | Rule | Good | Bad |
|---|---|---|---|
| Type | Noun phrase for what it is | `EventDraft`, `DayCount` | `EventData`, `ReminderManager` |
| Repository | `<Record>Repository`; `SwiftData<Record>Repository` | `EventRepository` | `EventStore`, `EventRepositoryProtocol` |
| Capability protocol | `-ing` | `ImportScanning`, `NotificationScheduling` | `ImportServiceProtocol` |
| Boolean | `is` / `has` / `can` / `should` | `isFocus`, `hasEndDate` | `pinned`, `endDateFlag` |
| Intent method | Verb phrase the user would say | `save()`, `togglePin(_:)` | `handleTap()`, `didPress()` |
| Query method | Noun phrase or `is…(_:)` | `isSelected(_:)`, `pinAction(for:)` | `getPin(_:)` |
| Closure property | What happens | `onRetry`, `onSelect` | `callback`, `handler` |
| Test double | Role suffix | `EventRepositorySpy`, `NotificationAuthorizerStub` | `MockStuff` |

- No abbreviations except `ID`, `URL`, `API`, `JSON`: `viewModel`, not `vm`.
- Never `data`, `info`, `item`, `manager`, `helper`, `coordinator` or `util` as a whole name.
- Do not repeat the type in member names: `event.title`, not `event.eventTitle`.

## Declaration order

Inside a type, one blank line between groups; inside a group, the order in which the caller uses
them. [The Home ViewModel](view-model.md#reference-implementation) follows it.

1. `@Environment`, `@State`, `@Binding` properties (views).
2. Stored properties, widest access first: `public`, `public private(set)`, `internal`,
   `private(set)`, `private let`, `private var`. Callback closures (`on…`) form their own group.
3. Initializers.
4. Computed properties.
5. `body` (views).
6. Intents, in the order the user meets them.
7. Queries.
8. Private steps. A step that serves one member sits directly below that member; a step several
   members share sits at the end. The file reads from each entry point down to its smallest step.

A long type (about 150 lines or more) may move its private members to a trailing
`private extension`; a short type never does. Small nested types (`HomeContent.Placeholder`) are
declared in an `extension` right after the type's body.

A file over 150 lines puts one `// MARK: - <Name>` above each top-level extension (`Private`, the
protocol of a conformance, or what the extension groups) and above the `#if DEBUG` previews
(`Previews`). Shorter files and the inside of a type have none.

## Access control

- Default is `internal`, written without a modifier. `public` only on what another module uses.
- Members used only in the file are `private`. Classes are `final`.
- A `public` type writes out a `public` initializer.
- Tests use `@testable import`; access is never widened for a test.

## Functions

- The top function reads like a table of contents of well-named private steps
  ([example](view-model.md#writes)). A new type is extracted only when a responsibility has its own
  state or is used elsewhere.
- More than four parameters usually means a value type is missing.
- A protocol type is written bare (`private let events: EventRepository`). `any` and `some` appear
  only where the compiler needs them: an opaque result (`some View`) or a protocol with an
  associated type.
- No boolean parameters that change behaviour (`load(force: true)`): two intents or an enum.
- Creating a value names its type (`HomeContent(…)`, `EventIssue(error)`), not `.init(…)`.

```swift
func events() -> EventsDependencies {
    EventsDependencies(
        events: eventRepository,
        categories: categoryRepository,
        notificationPermission: reminderService,
        calendar: .autoupdatingCurrent,
        now: { .now },
        settings: settings()
    )
}
```

## Control flow

- **Branch with `switch`**: over an enum, a tuple of the deciding values, an optional or a `Bool`.
  `if` only for one condition without `else`. Never an `else if` chain.
- A `switch` that produces a value is an expression; a case whose body is one value stays on the
  line of its label.

  ```swift
  public var tint: DaysMarkColor {
      switch self {
      case .past: .past
      case .today, .upcoming: .upcoming
      }
  }
  ```

- `guard` for preconditions; unwrap with the shorthand (`guard let self`, `if let event`).
- Mutually exclusive states are an `enum`, never a set of optionals and booleans.
- Ternaries only to pick between two simple values; never nested.
- No force unwraps, `try!` or `fatalError` outside tests and previews, except a `URL` from a
  literal and opening the model container ([persistence.md](persistence.md#the-container)).

## Errors

- Throwing APIs use typed throws: `throws(EventError)`.
- Each domain has one error enum (`EventError`, `CategoryError`, `ImportError`). A feature maps it
  to its own issue enum (`EventIssue`) with an exhaustive `switch`; the text a person reads is the
  issue's display, never `error.localizedDescription`.
- `try?` only when the caller does not care why something failed.

## No magic values

A literal that carries meaning gets a name, once, in the place that owns it. Never a `Constants`
type.

| Literal | Lives in |
|---|---|
| User-facing text | String Catalog, keyed where it is used ([localization.md](localization.md)) |
| Spacing, radii, sizes | `@Environment(\.dimensions)` ([user-interface.md](user-interface.md#spacing-and-sizes)) |
| Colors, fonts, SF Symbols, artwork | `DaysMarkColor`, `DaysMarkFont`, `DaysMarkImage` |
| Stored and system identifiers | The enum that owns them ([architecture.md](architecture.md#identifiers)) |
| Durations, limits, counts | A private computed property of the type that uses them (`private var pendingRequestLimit: Int { 64 }`) |

## No `static`

Write no `static` member, except:

1. a member a protocol requires (`==`, `AppIntent.title`, `AppEntity.defaultQuery`,
   `FeatureDestination.root`, …);
2. an extension that gives a protocol-typed SwiftUI or Foundation parameter its leading dot
   (`extension ButtonStyle where Self == DaysMarkButtonStyle { static func daysmark(_:) }`,
   `BundleDescription.module`);
3. a `static var mock…` or `static func mock…(…)` in a test target's [mock extension](#mock-data).

Everything else has a non-static home. A preset is an enum case (`BuiltInCategory.birthday`). A
helper is an instance member or an initializer (`DayCountCalculator(calendar:)`,
`AppRequest(url:)`). Something shared for the life of the app is one instance the composition
root creates and passes down. Localization keys are written where they are used.

## Mock data

Sample data is never a default value in production code. A draft starts from values its caller
passes (`EventDraft(startingOn: today, categoryID: categoryID)`), never from `Date.now` inside the
type.

| Data for | Lives in |
|---|---|
| A module's previews | `Preview Content/PreviewObjectPool.swift` of the module (and `PreviewObjectPool<Area>.swift` for a long area) |
| Tests | Mock extensions in the test target's `Mocks.swift` or `Mocks/<Subject>Mocks.swift` |
| Tests of several modules | `DaysMarkKit/Tests/TestSupport/Mocks.swift` |

- `PreviewObjectPool` is a `struct` whose members return new, isolated values and objects on
  every call: models in an in-memory container, repositories, dependencies and view models. A use
  writes `PreviewObjectPool().homeViewModel(.typical)`.
- `#if DEBUG` wraps `Preview Content/` files and the `#Preview` block at the end of a view file,
  and nothing else, apart from `CloudKitSchemaInitializer`
  ([persistence.md](persistence.md#cloudkit-constraints)).
- A mock is named `mock` for the only value of a type or a family built from parameters
  (`EventDraft.mock`, `CountdownEvent.mock(...)`), `mock<Name>` for one of several
  (`Date.mockNow`, `ModelContainer.mockInMemory()`).
- Names in preview data and mocks are made up; never a real person's.

## Comments

- No explanatory comments: no `//` notes, no `///` documentation. Rename or extract until the
  code explains itself.
- The only comments are the file header, `// swift-tools-version`, the `// MARK: -` lines above,
  and `// Given` / `// When` / `// Then` in tests. No commented-out code or `TODO`s.

## Extensions and collections

- Extend a standard type only to name an intention used in more than one place
  (`Calendar.strictDate(from:)`).
- Never extend a concrete collection (`extension [CountdownEvent]`); a collection with rules of
  its own is a domain type (`HomeContent`).

## Concurrency

- Swift 6 strict concurrency. No `@unchecked Sendable`, no `nonisolated(unsafe)`.
- Shared mutable state off the main actor is guarded by `Synchronization.Mutex` or an `actor`.
- Isolation follows [architecture.md](architecture.md#isolation); async work in a ViewModel
  follows [view-model.md](view-model.md#async-work).
