# Views

A view lays out values it is given and forwards what the user does. A screen's `body` shows at a
glance how many sections it has and where its presentations come from.

## The body is the table of contents

`DaysMarkKit/Sources/EventsFeature/Screens/Home/HomeView.swift`:

```swift
struct HomeView: View {
    @Environment(\.dimensions) private var dimensions
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.eventZoomNamespace) private var zoomNamespace

    @Bindable var viewModel: HomeViewModel
    @Binding var request: AppRequest?

    var body: some View {
        List(selection: $viewModel.selection) {
            if viewModel.content.showsOverview {
                HomeHeader(viewModel: viewModel)
            }

            ForEach(viewModel.content.rows) { row in
                Button {
                    viewModel.open(row.id)
                } label: {
                    EventRow(event: row.event, showsDisclosure: !isSidebar)
                }
                .zoomSource(id: EventZoomSource(eventID: row.id, isFocus: false), in: zoomNamespace)
                .swipeActions(edge: .leading) {
                    PinButton(pinAction: row.pinAction) { viewModel.togglePin(row.id) }
                }
                .swipeActions(edge: .trailing) {
                    DeleteButton { viewModel.delete(row.id) }
                    ShareButton { viewModel.share(row.id) }
                }
                .listRowBackground(Color.clear)
            }

            if let placeholder = viewModel.content.placeholder {
                HomeEmptyView(
                    placeholder: placeholder,
                    onAdd: { viewModel.addEvent() },
                    onResetFilters: { viewModel.resetFilters() }
                )
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .environment(\.editMode, editMode)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            HomeToolbar(
                viewModel: viewModel,
                canSelect: !viewModel.content.selectableIDs.isEmpty,
                showsAddAndSearch: !isSidebar
            )
        }
        .alert(issue: viewModel.issue, onDismiss: { viewModel.acknowledgeIssue() })
        .refreshes(viewModel.time, at: viewModel.content.nextChange)
        .handles($request) { viewModel.open($0) }
        .task { await viewModel.observeStore() }
    }

    private var isSidebar: Bool {
        horizontalSizeClass == .regular
    }

    private var editMode: Binding<EditMode> {
        Binding(viewModel.isSelecting ? .active : .inactive) {
            viewModel.isSelecting = $0.isEditing
        }
    }
}
```

- Each top-level section is a named view in the screen's `Components/`, named for what it shows
  (`HomeHeader`, `PinnedEventCard`), never where it sits (`TopView`).
- A section receives the values and actions it needs, not the ViewModel, unless it needs bindings
  or most of the ViewModel's intents (`HomeHeader`, `HomeToolbar`).
- The body chains to state (`viewModel.content.rows`, `row.pinAction`) and makes no decision the
  ViewModel or the content value can make ([principles.md](principles.md#who-reads-this-code)).
- Modifiers are SwiftUI's own, chained at the call site; a custom `ViewModifier` exists only when
  it holds state or behaviour (`.refreshes(_:at:)`, `.alert(issue:)`, `.handles(_:)`).
- Actions are written as closures, never passed by name: `onSelect: { viewModel.selectCategory($0) }`.
  Previews wrap every argument in a generic function, which breaks the conversion to SwiftUI's
  main-actor closure types.
- Small stateless fragments may stay as `private` computed views after `body`. Extract a type when
  a fragment has its own state, a meaningful branch or its own preview.

## Siblings

Views side by side in a container (`VStack`, `HStack`, `ZStack`, `List`, a `ViewBuilder` closure)
are separated by one blank line, so the eye counts the views before reading them:

```swift
VStack(alignment: .leading, spacing: dimensions.rowLineSpacing) {
    Text(verbatim: event.title)
        .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.eventTitle)
        .lineLimit(2)

    DayCountText(event: event, font: .rowPhrase)

    Text(verbatim: event.date)
        .textStyle(DaysMarkColor.textSecondary, DaysMarkFont.rowSecondary)
}
```

A single child, the cases of a `switch` and the branches of an `if` have no blank line before
them.

## Records

- A view never reads the store: no `@Query`, no `@Environment(\.modelContext)`, no
  `import SwiftData`. It starts its ViewModel's observation with
  `.task { await viewModel.observeStore() }` ([view-model.md](view-model.md#records)).
- A view never writes: no assignment to a model's property, no `@Bindable` on a model. A change is
  a ViewModel intent.
- The current time is the ViewModel's `CurrentTime`, refreshed by
  `.refreshes(viewModel.time, at: viewModel.content.nextChange)` when the next change is due. Only
  event detail and the Live Activity tick every second, in their smallest leaf view.

## State in the body

- `@State` lives in the smallest view that needs it. A value that changes often (the ticking line
  in event detail) is isolated in a leaf.
- Mutually exclusive content is a `switch` over an enum from the ViewModel, each case one line
  that calls an extracted piece.
- No conditional expressions that pick strings, symbols or colors: write
  `Image(style: action.image)`, never `Image(systemName: isFocus ? … : …)`.
- No literal numbers, strings or symbol names. Every size is read from
  `@Environment(\.dimensions)` ([user-interface.md](user-interface.md#spacing-and-sizes)).
- No `GeometryReader` for layout, and a size is never measured and then written to state.
  Adaptive layout uses `ViewThatFits`, `containerRelativeFrame` and `Grid`.

## Lists

- `List` → `ForEach` → row view is visible in the file.
- Screens that edit values (the event editor, special nodes, the category editor) are plain
  `List`s on the canvas, not `Form`s.
- A row that opens something is a `Button` that calls an intent.
- Swipe actions take their title and symbol from presentation values (`PinAction`); a control used
  in several places is a small `View` (`PinButton`, `DeleteButton`, `ShareButton`).
- Empty and no-match states are one placeholder row or an `.overlay`, never fake event rows.
- Rows are not inserted, removed or expanded with a custom animation inside a `List`.

## System controls first

A screen uses the system's navigation bar, toolbar, search field, sheets, menus, pickers, toggles,
swipe actions and confirmation dialogs with their system appearance, Liquid Glass included.

- Glass belongs to those controls. Event content (rows, the focus, cards) is flat on the canvas;
  nothing imitates glass by hand.
- A control is custom only when the system has none for the job, and then it is a DesignSystem
  component.

## Async work and lifecycle

- Work runs from `.task(id:)` on a request value the ViewModel holds, so SwiftUI starts, replaces
  and cancels it ([view-model.md](view-model.md#async-work)). Views hold no `Task`.
- A sheet with unsaved changes sets `.interactiveDismissDisabled(viewModel.hasUnsavedChanges)`.

Accessibility is in [user-interface.md](user-interface.md#accessibility); previews in
[testing.md](testing.md#previews).
