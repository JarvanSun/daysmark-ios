# User Interface

DesignSystem (`DaysMarkKit/Sources/DesignSystem`) owns every visual decision: colors, fonts,
images, sizes, button styles, the landscape, shared components and motion. Features and the widget
use its names, never raw values. It builds on SunKit's styling protocols (`ColorStyling`,
`FontStyling`, `ImageStyling`, `DimensionStyling`). Its folders and starting points are listed in
its `README.md`.

- A look applied to a system control is a style in `Styles/` with its leading-dot entry
  (`.buttonStyle(.daysmark(.primary))`).
- System modifiers are chained at the call site, even when the same chain appears on several rows.
  A `ViewModifier` in `Modifiers/` exists only when it holds state or behaviour
  (`.refreshes(_:at:)`, `.alert(issue:onDismiss:)`).
- A piece of interface used by two features or by the widget is a view in `Components/`. A
  feature keeps what only it reuses in its own `UserInterface/`.
- How a DaysMarkCore value looks is an extension in `Extensions/<Type>Extensions.swift`
  (`DayCountExtensions.swift`: the tint of each direction).

## The look

A warm ivory canvas, flat content and quiet color.

- Content is laid out with type, spacing, alignment and separators. No wall of rounded cards, no
  shadows under rows, no gradients behind text.
- The landscape illustration (`LandscapeIllustration`) appears on Home only. It takes the events'
  markers and draws; it never carries meaning on its own and never covers a title or a phrase.
- Dark mode has its own mapping for canvas and landscape; it is not an inverted light mode.

## Colors

- `DaysMarkColor` is an enum of semantic cases only (`canvas`, `textPrimary`, `textSecondary`,
  `separator`, `tint`, `upcoming`, `past`, `destructive`, `caution`, the landscape's grounds and
  foliage), each a color set in `Resources/Colors.xcassets` with light, dark and
  increased-contrast variants.
- Views apply colors with SunKit's `.foregroundColor(DaysMarkColor.…)` or
  `.textStyle(_:_:)`. Never `Color.red` or `Color(hex:)`.
- `tint` is the one accent. No feature defines a color of its own.
- `upcoming` and `past` color the direction of a phrase; the phrase always carries its direction
  word too.

## Fonts

- The app uses the system font. `DaysMarkFont`'s cases are roles (`eventTitle`, `rowPhrase`,
  `rowSecondary`, `detailNumber`, `widgetTitle`, …), each a system text style with a weight, so it
  scales with Dynamic Type. Never `Font.system(size:)`.
- Numbers that change in place use `.monospacedDigit()`.

## Images and symbols

- `DaysMarkImage`'s raw value is the SF Symbol name and each case is named after the symbol
  (`bell`, `chevronForward`), not after a use. Views write `Image(style: DaysMarkImage.bell)`. A
  symbol name never appears outside an `ImageStyling` enum.
- `EventAppearance` maps an event's stored appearance key to one of the built-in illustrated icons.
  Controls use SF Symbols; events use the illustrated icons.

## Spacing and sizes

Every length comes from one value, read in a view with
`@Environment(\.dimensions) private var dimensions`:

```swift
HStack(spacing: dimensions.spaceMedium) {
    …
}
.padding(.horizontal, dimensions.pageMargin)
```

- SunKit's generic tokens are used where they fit (`spaceSmall`, `cornerRadiusLarge`).
- An app-specific size is declared once, as a `DimensionStyling` property in
  `Appearance/Dimensions/DimensionStylingExtensions.swift` (`pageMargin`, `minimumTapTarget`,
  `eventIconColumnWidth`). A size only one module uses is declared the same way in that module's
  `UserInterface/Extensions/DimensionStylingExtensions.swift`.
- One property per role, named for what it sizes, never for its value. No view declares its own
  size constants or `…Dimensions` type.
- Dimensions hold lengths only; durations are `DaysMarkMotion` values.
- Every tappable element is at least 44 × 44 points.
- A column is as wide as its widest possible value (four-digit counts, long German units), so
  rows keep the same alignment for every event and language.

## Buttons

System controls keep their system look ([views.md](views.md#system-controls-first)). A button drawn
in content has a DesignSystem style, `.buttonStyle(.daysmark(kind))`:

| `DaysMarkButtonStyle.Kind` | Use |
|---|---|
| `.primary` | The one main action of a screen or placeholder (Share, Add, Continue) |
| `.bar` | The action pinned below scrolling content (onboarding steps, confirming an import) |
| `.secondary` | An alternative action (Skip, Reset filters) |
| `.caution` | An action that needs attention but deletes nothing (resolving a sync conflict) |
| `.row` | Tappable rows |

Every kind is built on the system's prominent or bordered button styles and keeps their pressed,
disabled and focused states. A destructive action is a `Button(role: .destructive)`.

## How an event is shown

The words of a phrase come from DaysMarkCore's `RelativeTimePhrase`
([localization.md](localization.md#relative-time)) and the absolute date from
`OccurrenceDateFormat`; DesignSystem decides only how they look. Components take these values,
never SwiftData models. Long titles and accessibility sizes reflow; nothing truncates a direction
word or a unit.

## Motion

- Every animation's timing is a `DaysMarkMotion` case. A view that animates reads
  `accessibilityReduceMotion` and writes
  `.animation(DaysMarkMotion.dayChange.animation(reducingMotion: reduceMotion), value:)`, never a
  curve or a duration.
- Digits roll in place with `.contentTransition(.numericText(countsDown:))`.
- `ConfettiView` is the one celebration: once, when event detail opens on the event's day.
- Content swaps use `.id` with `.transition(.identity)`: nothing cross-fades two versions of the
  same content.
- Expanding and collapsing never use a removal `.transition`. An edge the user is touching does
  not move while content below it grows.

## Accessibility

- **Dynamic Type.** Every text style scales; layouts are checked at the largest accessibility size.
- **VoiceOver.** An event row is one element that reads as a sentence ("Mary’s Birthday, in 12
  days, September 18"). Icon-only buttons have a label. A control whose visible text says what it
  does needs no label of its own.
- **Not color alone.** Direction, selection and state always have words or a symbol.
- **Reduce Motion.** No confetti; numbers replace without rolling.
- **Operable without gestures.** Every swipe action also exists as a button or menu item.
- **Mirrors.** Layouts use leading and trailing, never left and right. The landscape's past and
  future sides are the one fixed direction.
