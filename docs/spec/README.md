# Daysmark Spec

How code in this repository is written. Someone who has read it can add a feature that looks like
the code already there. The module overview and diagram are in the
[repository README](../../README.md#code).

- **The spec wins.** When code and spec disagree, the code is wrong, or the spec changes in the
  same change.
- **Rules guide judgment.** *Must* and *never* hold in nearly every case; *prefer* marks a
  default. A rule gives way when following it makes the code harder to read, and the reason is
  said in review ([principles.md](principles.md)).
- **Samples are binding.** A code sample shows the expected shape.
- **Reference feature.** Home in `EventsFeature`
  (`DaysMarkKit/Sources/EventsFeature/Screens/Home/`). When the spec does not cover a case, copy
  what Home does.

## Where to start reading

One path leads from the launch of the app to the database. Every screen is read the same way.

| Step | File | What it shows |
|---|---|---|
| 1 | `DaysMark/App/DaysMarkApp.swift` | The entry point: one `AppDependencies`, one window |
| 2 | `DaysMark/Root/AppRoot.swift` | Onboarding or the Home stack |
| 3 | `DaysMark/App/Composition/AppDependencies.swift` | Every repository and service the app creates and which feature receives it |
| 4 | `DaysMarkKit/Sources/EventsFeature/EventsHostView.swift` | The feature's only public view; `Navigation/` lists every screen it can show |
| 5 | `…/Screens/Home/HomeView.swift` | The screen: its sections, top to bottom |
| 6 | `…/Screens/Home/HomeViewModel.swift` | The screen's state and every decision about it |
| 7 | `DaysMarkKit/Sources/DaysMarkCore/Repositories/Events/` | `EventRepository`, the protocol the ViewModel calls, and its SwiftData implementation |

Nothing sits between these steps: the ViewModel calls a repository through its protocol, and the
repository reads and writes SwiftData.

## Files

| File | Answers |
|---|---|
| [principles.md](principles.md) | Who reads this code, and the design rules every file follows |
| [product.md](product.md) | The screens and what they do |
| [architecture.md](architecture.md) | Modules, what may import what, where a file goes |
| [persistence.md](persistence.md) | The store, CloudKit, repositories, drafts, revisions, date calculation |
| [swift-style.md](swift-style.md) | Formatting, files, naming, declaration order, control flow, mock data |
| [view-model.md](view-model.md) | The shape of every ViewModel |
| [views.md](views.md) | How screens are composed and what a `body` may contain |
| [user-interface.md](user-interface.md) | Colors, fonts, sizes, buttons, motion, accessibility |
| [system-surfaces.md](system-surfaces.md) | Widgets, Live Activities, App Intents, Spotlight, reminders, deep links |
| [localization.md](localization.md) | The five languages, String Catalogs, the relative-time phrase |
| [testing.md](testing.md) | Swift Testing, test doubles and mocks, previews |

## Commands

- Open `DaysMark.xcodeproj` and run the `DaysMark` scheme on an iPhone or iPad simulator. To run
  on a device, set your own team, bundle identifiers, App Group and iCloud container.
- `scripts/format.sh` after editing Swift; `scripts/format.sh --lint` must succeed.
- `scripts/test.sh` runs the App's tests and every `DaysMarkKit` test target;
  `scripts/test.sh <Module>` runs one (`DaysMarkCore`, `DesignSystem`, `EventsFeature`,
  `SettingsFeature`, `OnboardingFeature`, or `DaysMark` for the App). `DESTINATION` chooses the
  simulator, `XCODE_BUILD_ROOT` where builds go; the last line is always `RESULT: …`.
- Open `DaysMarkKit/Package.swift` to work on the modules without the App: each builds, tests and
  previews on its own.

The Xcode project is committed and uses synchronized folders: a file added, moved or deleted in
the file system is added, moved or deleted in its target.

## Adding a feature

1. Describe the behaviour in [product.md](product.md) and any new stored field in
   [persistence.md](persistence.md).
2. In DaysMarkCore: the model or draft, then the repository method that stores it (or a service,
   for a system framework), each with tests.
3. The ViewModel and its tests, then the views, previews and strings in all five languages.
4. Wire what is new into `AppDependencies`.

## Definition of done

- Builds without warnings; `scripts/format.sh --lint` and `scripts/test.sh` succeed; a bug fix has
  a test that failed before it.
- Every changed module builds, tests and previews on its own; its `README.md` still says what it
  contains.
- The path from view to store is direct
  ([architecture.md](architecture.md#no-needless-indirection)).
- Every new string exists in the five languages and was read in the screen at its real length.
- The change was looked at in the running app on iPhone and iPad, light and dark, at a large
  Dynamic Type size and with VoiceOver; a changed animation was recorded and its frames looked at.
- The spec still describes the code.

Commit messages are imperative and say what changed and why. Recordings, screenshot sets and
other large files stay outside the repository.
