# Principles

The design ideas behind every file, taken from *Clean Code*, *Refactoring* and *The Pragmatic
Programmer*. Every rule in this spec serves one goal: code a reader understands quickly. Where a
rule would make a piece of code harder to read, the code wins. Numbers are signals to take a
second look, never targets; applying a rule to the extreme is itself the mistake.

## Who reads this code

Daysmark is a showcase read by engineers and interviewers; it is not released and has no users to
protect. When simplicity and fidelity disagree, simplicity wins: a corner case, a pixel-perfect
detail or a migration path is deleted rather than kept at the cost of a concept the reader must
learn. A visible difference is mentioned in review, not engineered away.

- **Plain SwiftUI first.** Write what Apple's sample code writes: `List`, `NavigationStack` /
  `NavigationSplitView`, `NavigationLink(value:)`, `.swipeActions`, `.searchable`, system row
  insets, tints and separators. A custom version of something SwiftUI already does is removed.
- **No wrapper for a few lines.** A chain of system modifiers is written where it is used, even
  when it repeats. A `ViewModifier` exists only when it holds state or behaviour. No method on an
  enum returns a view (`EventAction.share.button`); a reusable control is a small `View`
  (`ShareButton`).
- **Views draw state.** A view reads what to show from its ViewModel and the content value it
  computes (`viewModel.title`, `row.pinAction`) and chains to it directly
  (`viewModel.content.rows`); it does not compute decisions or keep a local copy
  (`let content = viewModel.content`). `if let` / `if` on a state value is fine.
- **Compute once, where it is used.** A value used inside one function is a local `let` there. A
  computed property is cheap and side-effect free; work that builds a collection is a function
  (`namesByCategoryID()`), so the call site reads as a computation.
- **No edge-case machinery.** No code for states a reader would have to be told about: syncing a
  selection after a remote delete, accessibility identifiers with no UI tests, hover effects.
- **Plain names.** A name says what the thing is in everyday words (`PinnedEventCard`, `canvas`,
  `CurrentTime`), never a theme or brand (`LivingHorizon…`), never jargon a reader must look up.

## Simple first

- The simplest structure that does the job: no abstraction, protocol, layer, file or schema
  version until something needs it. A protocol earns its place when there is a second
  implementation or a test that must replace the real one.
- Structure that looks tidy but scatters one idea across many places makes the code harder to
  read, not easier.

## One responsibility

- A type has one reason to change. If describing it needs "and", look for two types.
- A repository owns the reads and writes of one kind of stored record; a service owns one
  capability.
- A function does one thing, at one level of detail. The top function reads like a short table of
  contents; the named steps it calls hold the detail.
- A file holds one concept: the main type and what belongs to it.

## Small and plain

- A function past about 20 lines, or nested more than two levels, deserves a second look for steps
  worth naming. A table-like `switch`, an initializer that wires dependencies, and a `body` made
  of named sections are often fine longer.
- A type past a couple of hundred lines is worth checking for a second responsibility.
- Many parameters, or the same values always passed together, usually mean a value type is
  missing.

## No hidden work

- An initializer mostly stores what it is given.
- Behaviour does not hide in `didSet`, `willSet` or a custom setter; a change with rules is a
  named intent method.
- A function either changes state or answers a question; a query has no side effects.

## Names

- A name says what something is for, so no comment is needed. No abbreviations, no type names in
  names (`eventsArray`), no empty words (`Manager`, `Helper`, `Data`, `Info`).
- A Boolean reads as an assertion: `isAllDay`, `hasTime`, `canSave`.

## Duplication and coupling

- Each piece of knowledge has one home; code repeated across modules moves to the lowest module
  both depend on.
- A change in one place should not force edits in many others; when it does, the knowledge is in
  the wrong place.
- Dead code is deleted.

## Folders

- A senior iOS developer finds the names they already know: `App/`, `Sources/`, `Tests/`,
  `Models/`, `Persistence/`, `Services/`, `Extensions/`, `Resources/`, `Screens/`, `Components/`,
  `Widgets/`. A name they would have to look up (`Values/`, `Schema/`, `SystemSurfaces/`) is the
  wrong name.
- A folder reads best when its contents fit in one glance: roughly eight files and a handful of
  sub-folders. Past that, files are grouped by subject, never by kind of file.
- A folder for one or two files usually adds a step without adding clarity.

A smell found while working is fixed in the same change.
