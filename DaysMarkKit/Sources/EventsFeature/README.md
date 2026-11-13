# EventsFeature

The main feature of Daysmark: Home, an event's detail, the editor and sharing. It owns the
navigation stack the whole app lives in, and on iPad the split view around it.

It is responsible for what each of those screens shows and decides, for opening what a link, a
notification or a keyboard command asks for. Each screen's ViewModel loads its records from
`EventRepository` and `CategoryRepository`, loads them again when the store changes (the editor
only while its draft is untouched), and asks the repository to save and delete events, set the
focus and resolve a conflict. It never touches SwiftData itself. Settings is another feature; `EventsDependencies` carries its
`SettingsDependencies` and the router pushes `SettingsHostView` like any other screen.

Start from `EventsHostView`, the only view the App can show, given
`EventsDependencies`, what the App passes in, and a binding to the `AppRequest` waiting to
be shown.

| Folder | Contains | Start from |
|---|---|---|
| `Navigation/` | the dependencies, every screen the feature can show, the router, what a request leads to | `EventsDestination`, `EventsRouter`, `RequestTarget` |
| `Screens/Home/` | the pinned event, the landscape, the category filter, the list, search, batch deletion | `HomeView`, `HomeViewModel`, `HomeContent` |
| `Screens/Detail/` | the count in days, weeks, hours or minutes, the ticking line, conflicts | `EventDetailView`, `EventDetailViewModel` |
| `Screens/Editor/` | the sheet that creates and edits; in `SpecialNodes/`, the page pushed from it | `EventEditorView`, `EventEditorViewModel` |
| `Screens/Sharing/` | the card, its rendering, the share sheet | `EventShareView`, `EventShareContent` |
| `Screens/Models/` | what several screens share: an event as it is shown, the time it is counted at, issues, pinning | `EventItem`, `CurrentTime`, `PinAction` |
| `UserInterface/` | what only this feature reuses: the zoom between a row and detail, how a pending request is handled, how other modules' values read (`EventDraftExtensions`) | `.zoomSource(id:in:)`, `.handles(_:handle:)` |
| `Resources/` | the feature's strings in five languages and its artwork | `Localizable.xcstrings` |
| `Preview Content/` | data and stand-ins for every preview | `PreviewObjectPool` |

Tests are in `DaysMarkKit/Tests/EventsFeatureTests/`, grouped by the same folders, with mocks in
`Mocks/` and the repository spies from `TestSupport`: `scripts/test.sh EventsFeature`.
