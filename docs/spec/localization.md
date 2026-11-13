# Localization

The app ships in English (development language), German, Simplified Chinese, Japanese and Korean.
Every user-facing string exists in all five on every surface: the app, the widget, notifications,
Siri and Shortcuts, Spotlight, the Live Activity and the share card.

## String Catalogs

- Each module that shows text has one `Resources/Localizable.xcstrings`, read with
  `bundle: .module`. A feature's `LocalizedStringResource.BundleDescription.module` is in
  `UserInterface/Extensions/BundleDescriptionExtensions.swift`.
- The App has `Localizable.xcstrings` (commands, App Intent titles and dialogs),
  `AppShortcuts.xcstrings` (App Shortcut phrases) and `InfoPlist.xcstrings` (the display name and
  usage texts). The widget extension has its own `Localizable.xcstrings`.
- A string lives in the catalog of the module that writes its key. No target reads another
  module's catalog.
- A key is written once, where it is used: no key enums, no `static` text. A key is never
  assembled at run time (`"event.\(kind).title"`).
- Keys are semantic and dotted, `<feature>.<screen or component>.<element>`
  (`home.empty.title`, `phrase.future.days`), never the English sentence. The exception is an App
  Shortcut phrase, whose key the system requires to be the phrase.
- Every key has a catalog comment saying where it appears.
- Plurals are defined in the catalog, never with `if count == 1`. Simplified Chinese, Japanese and
  Korean have `other` only.
- Copy uses typographic apostrophes and quotes (`Mary’s Birthday`, German `„%@“`) and sentence
  case for buttons.

## In code

- A screen-level string is keyed in the view: `Text("settings.title", bundle: .module)`.
- Text that describes a model is a `LocalizedStringResource` in the type's display code, one key
  per case:

  ```swift
  var title: LocalizedStringResource {
      switch self {
      case .pin: LocalizedStringResource("event.focus.set", bundle: .module)
      case .unpin: LocalizedStringResource("event.focus.remove", bundle: .module)
      }
  }
  ```

- Strings stay lazy until a `Text` renders them. `String(localized:)` is used only for text that
  leaves as a `String`: DaysMarkCore's phrases and confirmations, a notification's body, a
  Spotlight attribute, the share card.
- Never concatenate localized pieces. A sentence with values is one key with interpolation, so
  each language can reorder it.
- `Text(verbatim:)` only for values that are not language: an event's title, a custom category's
  name.

## Relative time

The phrase that says how far an event is ("in 12 days", "vor 12 Tagen", "还有 12 天", "Today") is
written once, in DaysMarkCore's `Models/DayCount/` (`RelativeTimePhrase`), and used by every
surface.

- Direction word, number and unit are one catalog entry with plural variants. No code joins a
  direction word to a number or assumes the number comes first.
- Every surface uses the full phrase. Only a Lock Screen accessory may show a short form, and its
  accessibility label is the full phrase.
- A translation is checked in the screen at its real length; text that does not fit gets a shorter
  native wording, not a smaller font.

## Numbers and dates

- Dates use the system `Date.FormatStyle`s and DaysMarkCore's `OccurrenceDateFormat`, never fixed
  patterns.
- The locale, calendar and time zone come from the environment in views and are parameters
  everywhere else.
- Layouts hold German's long words, four-digit counts and the largest text size without
  truncating; a line that does not fit stacks.

## Testing

- `LocalizationCatalogTests` (`DaysMarkTests/Resources/`) reads every catalog of the app, the
  widget and the modules and fails when a key lacks one of the five languages or a plural
  category its language needs.
- `RelativeTimePhraseTests` checks every phrase and unit in every language against the table in
  [product.md](product.md#relative-time).
- Every screen's preview state has a `german` case ([testing.md](testing.md#previews)).
