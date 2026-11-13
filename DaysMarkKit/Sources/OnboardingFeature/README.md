# OnboardingFeature

The first-launch flow: a welcome page, the user's own birthday on a wheel, then a list of
ready-made events to start with. The App shows it once, before Home, and is told when it is done.

It is responsible for what the three steps show and in which order, which ready-made events are
offered and selected, and for asking DaysMarkCore to create them. It never writes to the store
itself: confirming or skipping is one call to `OnboardingCompleting`.

Start from `OnboardingHostView`, the only view the App can show, and `OnboardingDependencies`,
what the App passes in.

| Folder | Contains | Start from |
|---|---|---|
| `Navigation/` | the dependencies, the router and the host that owns the ViewModel | `OnboardingNavigationHost` |
| `Screens/Onboarding/` | the one screen: its view, its ViewModel, the content it shows and its texts | `OnboardingView`, `OnboardingViewModel`, `OnboardingContent` |
| `Screens/Onboarding/Components/` | the pieces of the screen, top to bottom | `OnboardingHeader`, `OnboardingCandidateRow` |
| `UserInterface/Extensions/` | how a seed and a day count read | `OnboardingSeedExtensions` |
| `Resources/` | the flow's strings in five languages | `Localizable.xcstrings` |
| `Preview Content/` | data and stand-ins for every preview | `PreviewObjectPool` |

Tests are in `DaysMarkKit/Tests/OnboardingFeatureTests/`, grouped by the same folders:
`scripts/test.sh OnboardingFeature`.
