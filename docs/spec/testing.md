# Testing and Previews

## Swift Testing

- Every test uses Swift Testing (`@Test`, `#expect`, `#require`). No XCTest and no UI test
  target: user flows are checked in the running app.
- One test file per source file with logic, mirroring its path:
  `Sources/EventsFeature/Screens/Home/Models/HomeContent.swift` →
  `Tests/EventsFeatureTests/Screens/Home/Models/HomeContentTests.swift`. It holds one
  `struct <Type>Tests`.
- The App's code is tested in `DaysMarkTests`. The widget extension has no tests of its own: its
  logic is in DaysMarkCore's `Services/Widgets/`.
- Views are not unit-tested; previews verify them.

## Test shape

```swift
@Test(arguments: [false, true])
func togglePinThenPinsOrUnpinsTheEvent(wasPinned: Bool) {
    // Given
    let event = CountdownEvent.mock()
    let events = EventRepositorySpy(
        storedEvents: [event],
        storedFocusSelections: wasPinned ? [.mock(selecting: event.id)] : []
    )
    let viewModel = makeViewModel(events: events)
    viewModel.reload()

    // When
    viewModel.togglePin(event.id)

    // Then
    #expect(events.selections == [wasPinned ? nil : event.id])
    #expect(viewModel.issue == nil)
}
```

- Name: `<method>When<condition>Then<result>`; drop `When…` when there is no condition.
- Comments are `// Given`, `// When`, `// Then` (or `// Given / When` when building the subject is
  the step under test); a body that is only the expectation has none.
- One behaviour per test. Variations use `@Test(arguments:)`, not copied tests.
- The system under test is built by a private `make…` function at the end of the test type.
- Tests never sleep and never read the clock: "now", the calendar and the time zone are passed in
  (`Date.mockNow`, `Calendar.mockGregorianUTC`).

## Test doubles and mocks

No mocking frameworks.

A test double stands in for one protocol, one type per file, in the test target's `Stubs/` or in
`TestSupport/Stubs/` when several targets replace it. Sample values are
[mock extensions](swift-style.md#mock-data).

| Suffix | Does |
|---|---|
| `Stub` | Returns canned values (`NotificationAuthorizerStub`) |
| `Spy` | Records calls in `private(set)` arrays and returns what it was given (`EventRepositorySpy`) |
| `Fake` | A working lightweight implementation, kept in memory |

- `TestSupport` holds the doubles several test targets share (`EventRepositorySpy`,
  `CategoryRepositorySpy`, `SystemSurfaceRefresherSpy`, …). Its types are `public`; the App never
  links it, so `DaysMarkTests/` keeps its own `Stubs/` and `Mocks.swift`.
- A feature's own `Stubs/` holds what only it replaces, such as its router (`EventsRouterSpy`).
- DaysMarkCore's tests run the real repository on `ModelContainer.mockInMemory()`: in memory,
  without CloudKit, new for every test.
- Tests never use `PreviewObjectPool`: it is preview data, not a mock.

## What must be tested

| Type | Tests |
|---|---|
| ViewModel | Every intent, placeholder case and issue |
| Content values, display extensions | Every rule and `switch` branch |
| Date calculation | 30 February rejected, a leap month kept, Umm al-Qura round trips, the 31st skipped, 29 February only in leap years, components unchanged across time zones; today, tomorrow, ranges, the focus tie-break |
| A repository | Every read and write on an in-memory store: what was saved, the revision appended, what was refreshed, every failure |
| Revisions, deleting, repair | Siblings kept, resolution, delete and restore, the marker beating a late copy, repair run twice |
| A service | What it asks the system framework and the repositories, every failure |
| `AppRequest`, stored identifiers | Every URL form both ways; every raw value |
| DesignSystem | Every token's default and override, every `DaysMarkMotion` timing, every button kind |

## Previews

One `#Preview` at the end of each view file, inside `#if DEBUG`. Never a separate preview file,
never one `#Preview` per state.

```swift
#if DEBUG
#Preview("Home", arguments: EventsPreviewState.allCases) { state in
    @Previewable @State var request: AppRequest?

    NavigationStack {
        HomeView(
            viewModel: PreviewObjectPool().homeViewModel(state),
            request: $request
        )
    }
    .environment(\.locale, state.locale)
}
#endif
```

- A screen previews over `<Feature>PreviewState`: typical, a single event, empty, no match, long
  titles, and `german` (the canvas has no language switch). A row or component stacks its
  variants in one preview; a widget view has one `#Preview(as:)` per family.
- Color scheme, Dynamic Type and orientation are checked with the canvas Variants.
- Data and view models come from the module's `PreviewObjectPool`: a ViewModel reads through the
  real repositories from an in-memory store filled for the state. The date it treats as now is
  fixed, so a preview shows the same numbers every day.
