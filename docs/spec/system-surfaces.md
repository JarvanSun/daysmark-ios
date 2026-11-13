# System Surfaces

Everything Daysmark shows or does outside its own screens. All of them show the same phrase, order
and focus as the app, because all of them call the same DaysMarkCore code
([persistence.md](persistence.md#deterministic-dates)). None has date logic of its own, and none
deletes anything.

| Surface | Code | Reads through | Writes |
|---|---|---|---|
| Widgets | `DaysMarkWidget/Widgets/` | `Services/Widgets/` on the read-only store | Never |
| Live Activity | UI in `DaysMarkWidget/LiveActivity/`; started by `LiveActivityService` | `ImportantDateActivityAttributes` | Never |
| App Intents | `DaysMark/App/Intents/` | `EventLookup` | Through the same `EventRepository` as the screens |
| Spotlight | `SpotlightIndexer` | The main context | The index only |
| Reminders | `ReminderService` | The main context | Pending notifications only |
| Background refresh | `DaysMark/App/Lifecycle/BackgroundRefresh.swift` | — | Calls `ReminderService` |
| Links | `AppRequest`; delivered by `DaysMark/Root/Navigation/` | — | — |

## After a write

A repository that saved calls `SystemSurfaceRefresher.refresh()`. The refresher is one
DaysMarkCore type created by the composition root; each pass does, in order:

1. `ReminderService.reconcile()`,
2. reload widget timelines (`WidgetReloading`),
3. `SpotlightIndexer.reindex(at:)`,
4. `LiveActivityService.reconcile(at:)`.

A refresh requested while a pass runs queues one more pass. `AppLifecycle` runs the same refresh
after repair when the app becomes active and after every finished CloudKit import
([persistence.md](persistence.md#repair)). ViewModels, views and intents never call any of the
four.

## Widgets

- **Focus** (`WidgetKind.focus`: small and the Lock Screen accessories) and **Important dates
  list** (`WidgetKind.list`: medium and large). Both are configured with an
  `AppIntentConfiguration`: automatic focus, one event, one category or all events.
- A source that no longer exists shows an "unavailable" state that opens the app; the widget never
  substitutes another event. A tap opens the event or the category in the app.

```text
Provider (DaysMarkWidget/Widgets/<Widget>)
   ▼  WidgetContentRequest: source, family, now
WidgetContentReader (Services/Widgets)   opens the store with StoreRole.widget
   ▼  events, categories, focus
WidgetContentResolver                    same EventSorter and DayCountCalculator as Home
   ▼  WidgetContent: rows or an unavailable state
Views                                    DesignSystem components
```

- A provider reads, builds a timeline and returns; it performs no write. A timeline covers seven
  days with at most 48 entries, each computed for its own date.
- A widget view is a function of its entry: no ViewModel, no state, no store access.
- The configuration intents, entities and queries live in `DaysMarkWidget/Intents/`.

## Live Activities

- Only for an event with a time, starting one hour before it. The app starts it when it launches
  or becomes active inside that window; there is no push-to-start.
- A single moment shows "Now" on arrival and ends 15 minutes later; a range counts to its end.
- `LiveActivityPlanner` decides, from an occurrence and `now`, whether an activity should run and
  when it ends. `LiveActivityService` requests, updates and ends activities to match.
- The countdown is the system's timer text, so it ticks without updates from the app.

## App Intents

| Intent | Does |
|---|---|
| `FindImportantDatesIntent` | The nearest events, at most three, in Home's order |
| `GetImportantDateDistanceIntent` | The phrase for one event |
| `OpenImportantDateIntent` | Opens event detail |
| `CreateImportantDateIntent` | Creates an event, after confirmation, on an unlocked device |
| `EditImportantDateIntent` | Changes title, date, time or category, after confirmation, on an unlocked device |

- Every intent, entity, query and the `AppShortcutsProvider` stay in the app target, in
  `DaysMark/App/Intents/`: the intents in `Actions/`, entities and queries in `Entities/`.
- `perform()` is short: read parameters, call `EventLookup` or `EventRepository`, return a result.
  Matching, candidates and confirmation text are in DaysMarkCore's `EventLookup`, so they are
  tested without AppIntents.
- Intents receive what they call with `@Dependency`. `AppDependencies` registers the same
  instances the screens use, once, at launch. An intent never builds a container or a repository.
- `OpenImportantDateIntent` sets the pending `AppRequest`; it does not navigate by itself.

## Spotlight

- `SpotlightIndexer.reindex(at:)` replaces the whole domain with the current visible events. An
  event hidden from Spotlight or deleted is not indexed.
- An item's identifier is the event ID and its URL is `AppRequest.event(id).url`.

## Reminders

Notifications are local. iOS keeps at most 64 pending requests per app, so the app decides which
64.

```text
ReminderService.reconcile()
   ▼  every reminder and special node still in the future, for every visible event
ReminderPlanner       fire date of each, through EventOccurrenceResolver
   ▼  sort by fire date, the focus first at the same moment; keep the first 64
NotificationScheduling     add what is missing, remove what is stale; never clear and rebuild
```

- An ordinary reminder's identifier is `<eventID>.<ruleID>.<occurrence>`; a special node's is
  `<eventID>.special.<nodeID>.<occurrence>`.
- "N days before" counts from the next occurrence; "N days since" and "Nth anniversary" count from
  the event's first start date.
- The body is the phrase for that moment, resolved when the request is scheduled. `userInfo`
  carries the event ID and its link under `NotificationPayloadKey`.
- Permission is requested by `ReminderService` when a ViewModel asks. Without permission,
  reminders are stored and nothing is scheduled.
- `NotificationScheduling` and `NotificationAuthorizing` wrap the notification center so tests
  replace it.

## Background refresh

One `BGAppRefreshTask`, `com.example.daysmark.reminderRefresh`, requested no sooner than six hours
ahead. It runs `ReminderService.reconcile()`, schedules the next request and completes exactly
once. `BackgroundRefresh` registers it at launch.

## Deep links

`AppRequest` (DaysMarkCore, `Models/DeepLinks/`) names everything the outside can ask the app to
show.

| Request | URL |
|---|---|
| `event(CountdownEvent.ID)` | `daysmark://event/<uuid>` |
| `category(EventCategory.ID)` | `daysmark://category/<uuid>` |
| `collection(.all / .birthdays / .anniversaries)` | `daysmark://collection/all`, `/birthdays`, `/anniversaries` |
| `widgets` | `daysmark://widgets` |

- `AppRequest(url:)` parses and `request.url` builds; no other code writes the scheme, a host or a
  path. Anything unexpected is not a request.
- Sources: `onOpenURL` (widgets, Live Activities), a tapped notification, a Spotlight result,
  `OpenImportantDateIntent` and the menu commands. Each becomes an `AppRequest` in
  `DaysMark/Root/Navigation/` and waits in `AppRootViewModel` until the interface exists.
- `EventsHostView` receives it as a binding, validates it against the store and commits it to the
  router: a visible event opens detail, a recently deleted one opens Recently Deleted, a category
  selects it on Home, `widgets` opens the widget instructions.
- An open sheet is never replaced by a request.
