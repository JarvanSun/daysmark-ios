# DesignSystem

Everything Daysmark shows that more than one screen uses. The app, the widget extension and the
three features link it, so a color, a size, a symbol or a row looks the same wherever it appears.

It owns the app's look: the palette, type roles, symbols and illustrated event icons,
every length a view uses, named animations, button styles, the landscape drawn on Home, and the
rows and groups that screens are built from. It builds on SunKit's styling protocols and knows
nothing about Daysmark's data: it does not import DaysMarkCore. A feature turns its values into
what a component takes (`DayCount.landscapeMarker`, a reminder time as minutes).

A view reads a value from `Appearance/` instead of writing a literal; a chain of system modifiers
is written where it is used, even when it repeats. Every length comes from one value,
`@Environment(\.dimensions)`; a feature that needs a size of its own adds it to the same type in
its `UserInterface/Extensions/DimensionStylingExtensions.swift`.

| Folder | Contains | Start from |
|---|---|---|
| `Appearance/Colors/` | semantic colors, each a color set in `Resources/Colors.xcassets` | `DaysMarkColor` |
| `Appearance/Fonts/` | type roles, all system text styles | `DaysMarkFont` |
| `Appearance/Images/` | SF Symbols and the illustrated event icons | `DaysMarkImage`, `EventAppearance` |
| `Appearance/Dimensions/` | the app's lengths as `DimensionStyling` properties | `dimensions.pageMargin` |
| `Appearance/Motion/` | named animations | `DaysMarkMotion` |
| `Components/` | the landscape, event icon, settings rows and groups, scrolling page, confetti, reminder time picker, widget notice | `LandscapeIllustration`, `SettingsRow`, `SettingsGroup`, `PageScrollView` |
| `Styles/` | the look of a button drawn in content | `.buttonStyle(.daysmark(.primary))` |
| `Modifiers/` | the `ViewModifier`s that hold state or behaviour, one per file with the protocol it reads and the `View` extension that applies it | `IssueAlertModifier` (`.alert(issue:onDismiss:)`), `MomentRefreshModifier` (`.refreshes(_:at:)`) |
| `Extensions/` | one file per extended type | `Label(_:symbol:)` |
| `Resources/` | color sets, artwork and the module's strings | `Colors.xcassets`, `Assets.xcassets` |

Tests are in `DaysMarkKit/Tests/DesignSystemTests/`, grouped by the same folders:
`scripts/test.sh DesignSystem`.
