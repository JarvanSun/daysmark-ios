# ViewModels

A ViewModel holds the state of one screen and every decision about it. What can be decided
without SwiftUI is decided here, so a unit test covers it.

## Shape

- Every screen that writes, has more than one state or navigates has one. A view that only lays
  out values it was given has none (the Settings root, the widget instructions).
- `@Observable final class <Screen>ViewModel`, `internal`, in the screen's folder. One per screen;
  a section shares its screen's ViewModel.
- Imports Foundation, Observation and DaysMarkCore. Never SwiftUI, DesignSystem, SwiftData or
  UIKit; never holds a `ModelContext`.
- Created by the navigation host or the router, owned with `@State`, passed down as
  `let viewModel` or `@Bindable var viewModel`.
- Every dependency is an `init` parameter typed as its DaysMarkCore protocol and stored as
  `private let`: starting values first (an event ID), repositories and services next, then the
  time, the router last. No default arguments.
- It lists only what it calls: Home takes `EventRepository` and `CategoryRepository`; Import takes
  `ImportScanning` and `ImportApplying`.

## Records

A screen that shows stored records loads them from the repositories and loads them again whenever
the store changes, so a change from the app, another device or an App Intent reaches the screen
([persistence.md](persistence.md#reads-and-writes)): `observeStore()` calls `reload()`, then
again for every value of `events.changes()`
([reference implementation](#reference-implementation)).

- What the screen loaded is one value, `private(set) var data` (`HomeData`). `reload()` reads
  every repository the screen needs into it.
- The view starts `observeStore()` with `.task`, so SwiftUI cancels it with the screen.
- The screen's content is one derived value, `content` (`HomeContent`), computed from the data,
  the time and the filter. Filtering, sorting, each row's state and the placeholder are decided
  there, so the view only draws.
- Models are read-only here. A change is a repository call that takes an ID or a draft.
- The ViewModel never asks what time it is. It owns `let time: CurrentTime`, which its creator
  passes in so a test chooses it ([persistence.md](persistence.md#deterministic-dates)).

## State

- Stored state is `private(set) var`. The only writable `var`s are values a view binds to
  (`filter`, `selection`, the editor's `draft`).
- What the screen is doing is one enum (`ImportActivity`: `idle`, `scanning`, `reviewing`,
  `applying`, `imported`), never `isLoading` plus `error` plus `hasLoaded`.
- A failed write is one optional issue enum (`issue: EventIssue?`) the view shows as an alert and
  clears with `acknowledgeIssue()`. Never an `errorMessage: String`.
- What the screen shows instead of content is a derived optional enum, `placeholder`
  (`noEvents`, `noMatches`), computed with one `switch`.
- An editor keeps one `draft` and the draft it started from; `hasUnsavedChanges` compares them
  ([persistence.md](persistence.md#drafts)).

## Intents

Every user action is one method named after what the user does. It guards its precondition,
changes state, calls the repository or service, then navigates, in that order. It returns nothing;
a view never branches on a `Bool` an intent returned. A choice with consequences goes through an
intent (`selectCategory(_:)` also clears the selection) instead of a binding.

## Writes

Repository calls on the main context are synchronous and throw one typed error, so a write is a
straight line (`togglePin(_:)` in the [reference implementation](#reference-implementation)).

- `perform(_:)` catches the domain error and stores its issue, so the intent has no
  `do / catch`.
- After a write the ViewModel changes nothing by hand: the save reaches `observeStore()`, and the
  repository has already refreshed reminders, widgets, Spotlight and Live Activities
  ([system-surfaces.md](system-surfaces.md#after-a-write)).

## Async work

Only a few intents wait: scanning Contacts or the calendar, applying an import, asking for
notification permission, completing onboarding, rendering a share card.

- Async intents are `async`, called from `.task` / `.task(id:)`, and never create a `Task`.
- Cancellation is checked once, right after each `await`; a cancelled call changes nothing.
- What starts work again is a request value the ViewModel holds (`scanRequest`) and the view
  observes with `.task(id:)`. An intent that reruns replaces it.
- Old content stays visible while work runs.

## Queries for the view

The view asks; it never computes. A question about an element is a method (`isSelected(_:)`,
`pinAction(for:)`), a question about the screen a property (`placeholder`, `canSave`). They return
named values with presentation, never `Bool` pairs the view turns into strings or symbols.

## Reference implementation

`DaysMarkKit/Sources/EventsFeature/Screens/Home/HomeViewModel.swift`, shortened to one intent of
each kind:

```swift
@Observable
final class HomeViewModel {
    var filter = HomeFilter()
    var isSelecting = false
    var selection: Set<CountdownEvent.ID> = []

    let time: CurrentTime
    private let events: EventRepository
    private let categories: CategoryRepository
    private let router: EventsRouting

    private(set) var data = HomeData()
    private(set) var issue: EventIssue?

    var content: HomeContent {
        data.content(filter: filter, at: time)
    }

    init(
        events: EventRepository,
        categories: CategoryRepository,
        time: CurrentTime,
        router: EventsRouting
    ) {
        self.events = events
        self.categories = categories
        self.time = time
        self.router = router
    }

    func observeStore() async {
        reload()

        for await _ in events.changes() {
            reload()
        }
    }

    func reload() {
        do {
            data = try HomeData(
                events: events.events(),
                categories: categories.categories().filter { $0.deletedAt == nil },
                pinnedEventID: FocusSelectionResolver().selectedEventID(
                    selections: events.focusSelections(),
                    revisions: events.focusSelectionRevisions()
                )
            )
        } catch {
            issue = EventIssue(.storeFailure)
        }
    }

    func addEvent() {
        guard !isSelecting else { return }

        router.showEditor(for: .new(categoryID: content.newEventCategoryID))
    }

    func togglePin(_ id: CountdownEvent.ID) {
        let pinnedEventID = content.pinAction(for: id).pinnedEventID

        perform(try events.setFocus(eventID: pinnedEventID))
    }

    func delete(_ id: CountdownEvent.ID) {
        perform(try events.delete(eventID: id))
    }

    @discardableResult
    private func perform(_ change: @autoclosure () throws(EventError) -> Void) -> Bool {
        do {
            try change()
            issue = nil
            return true
        } catch {
            issue = EventIssue(error)
            return false
        }
    }
}
```

`HomeContent` (`Screens/Home/Models/`) is a value: the pinned row, the landscape counts, the
category choices, the rows in order, the placeholder and the next time the screen must recompute.
It is built from `EventSorter`, `EventOccurrenceResolver` and `DayCountCalculator` and has no date
logic of its own.
