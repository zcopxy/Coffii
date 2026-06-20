# Coffii

An espresso-only iOS shot log. SwiftUI + SwiftData, local-first, no account.
The hero mechanic is an auto-generated, shareable "Shot in Review" card.

## Build commands

The Xcode project is generated from `project.yml` via XcodeGen. Regenerate after
adding/removing files:

```
xcodegen generate
```

Build for the iOS Simulator (generic destination compiles without booting a sim):

```
xcodebuild -project Coffii.xcodeproj -scheme Coffii \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build build
```

Build and run on a booted simulator (e.g. iPhone 16 Pro, iOS 18.5):

```
xcrun simctl boot "iPhone 16 Pro"
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/Coffii.app
xcrun simctl launch booted com.coffii.app
```

There is no `npm run lint` / `typecheck` equivalent yet — Swift compile via
`xcodebuild` is the source of truth. Unit/snapshot tests arrive with Phase 4+.

## Architecture

- `CoffiiApp.swift` — `@main`, `ModelContainer` for all five `@Model` types.
- `RootView.swift` — 3-tab `TabView`: Today / Beans / Settings.
- `Model/` — SwiftData models (`Shot`, `Bean`, `Grinder`, `Machine`, `Basket`)
  + `TasteTag` / `RoastLevel` enums + `Identifiable` conformances.
- `DesignSystem/` — `Palette` (asset-backed Warm Editorial tokens),
  `Typography`, `WarmCard`, `PrimaryButton`/`SecondaryButton`, `StatChip`,
  `TasteTagToggle`, `EspressoIcon`.
- `Features/Today/` — `HomeView`, `LastGoodPullCard`, `NextShotBanner`.
- `Features/Logging/` — `LogShotView`, `ShotTimerView`, `ShotDraft`,
  bean/gear edit sheets, `PhotoPicker`.
- `Features/Card/` — `ShotCardView`, `CardTheme`, `CardRenderer`,
  `CardRevealView` (signature animation), `ShareSheet`.
- `Features/Beans/` — `BeanListView`, `BeanDetailView`.
- `Features/Settings/` — minimal v1 `SettingsView` (Pro/export deferred).
- `Services/` — `HapticEngine` (`PurchaseManager` + `ExportService` arrive in Phase 5).

## SwiftData gotcha

`@Model` classes with a `@Relationship` reject leading-dot default values on
stored properties (e.g. `var createdAt: Date = .now`). Use the fully-qualified
form: `var createdAt: Date = Date.now`. `@Attribute(.unique)` ids are assigned
in `init`, not at the property declaration.

## Status

Phases 0–3 (demoable core) are complete and build cleanly. The end-to-end loop
— log a shot with the live timer → save → card reveal with the signature
animation → share — is wired. Phases 4–6 (Charts, diff card, StoreKit paywall,
export, onboarding, dark-mode/a11y pass) remain.

## Open decisions (carry forward)

- Final name (placeholder **Coffii** currently used for display, bundle
  `com.coffii.app`, and the card watermark).
- Default card theme details before Phase 3 sign-off.
- iCloud sync timing (schema left CloudKit-compatible; no container in v1).
