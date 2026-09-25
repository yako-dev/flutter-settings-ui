# settings_ui: agent instructions

Instructions for coding agents (Claude Code, Codex and others) working in this repository.
`CLAUDE.md` only imports this file (`@AGENTS.md`); edit this file, and keep `CLAUDE.md` as that one line.

## About this project

`settings_ui` is a published Flutter package (pub.dev: `settings_ui`, current version: `4.0.0`) that renders native-looking settings screens for iOS, macOS, Windows, Android, Linux, Fuchsia and the web from a single API. It is used in production by thousands of apps, so treat every public API and default-look change as a breaking change for someone.

- Requires Flutter >=3.44 and Dart >=3.12.
- Built on the decoupled [`material_ui`](https://pub.dev/packages/material_ui) and [`cupertino_ui`](https://pub.dev/packages/cupertino_ui) packages. In `lib/`, `test/` and `example/`, import `package:material_ui/material_ui.dart` and `package:cupertino_ui/cupertino_ui.dart` (plus non-design libraries such as `package:flutter/widgets.dart`, `foundation.dart`, `services.dart`). Never import `package:flutter/material.dart` or `package:flutter/cupertino.dart`: their `Theme`/`CupertinoTheme` are different classes, so the package would stop seeing the app theme.
- Apps that have not moved to material_ui stay on `settings_ui ^3.0.1`.

## Commands

```bash
flutter pub get

# Format (CI fails on unformatted code). `flutter format` no longer exists.
dart format .
dart format --output=none --set-exit-if-changed .   # CI check

# Lint
flutter analyze .

# All unit/widget tests, as CI runs them
flutter test --coverage --test-randomize-ordering-seed random

# One group or test (the files in test/settings_tests have no main())
flutter test test/widget_test.dart --name "CupertinoSettingsSwitch"

# Example app, and its integration test (needs a running device, simulator or emulator)
cd example && flutter run
# On the web the URL can pick the screen, style and brightness
# (example/lib/utils/launch_options.dart), e.g. /?screen=windows-display&theme=dark
cd example && flutter run -d chrome
cd example && flutter test integration_test/integration_test.dart -d <device-id>
```

## Architecture

### Platform dispatch

Every public widget (`SettingsSection`, `SettingsTile`) is a thin dispatcher. At build time it reads `SettingsTheme.of(context).platform` and returns one of five implementations:

- `iOS`, `macOS` → iOS style (`platforms/ios_*`)
- `windows` → Windows 11 (Fluent) style (`platforms/fluent_*`)
- `android`, `fuchsia` → Android style (`platforms/android_*`)
- `linux` → GNOME (libadwaita) style (`platforms/adwaita_*`)
- `web` → web style (`platforms/web_*`)

```
lib/src/tiles/
  settings_tile.dart              ← dispatcher
  platforms/
    android_settings_tile.dart
    ios_settings_tile.dart
    web_settings_tile.dart
    fluent_settings_tile.dart
    adwaita_settings_tile.dart
    cupertino_settings_switch.dart  ← public, used by the iOS tile
    fluent_settings_switch.dart     ← public, used by the Windows tile
    adwaita_settings_switch.dart    ← public, used by the GNOME tile
```

Same pattern for `lib/src/sections/`. `lib/src/list/settings_list.dart` resolves the platform, brightness and default padding.

### Theme propagation

`SettingsList` resolves the platform and brightness, gets the style defaults from `ThemeProvider.getTheme()`, merges the user's `lightTheme`/`darkTheme` (`SettingsThemeData`) over them, and pushes the result down through `SettingsTheme` (an `InheritedWidget`). Tiles and sections read `SettingsTheme.of(context).themeData`; never pass theme values through constructors.

`ThemeProvider` (`lib/src/utils/theme_provider.dart`) holds the defaults: Android and web derive colors from the Material 3 `ColorScheme`; iOS, Windows and GNOME use fixed system colors (iOS system colors, WinUI theme resources from `lib/src/utils/fluent_tokens.dart`, libadwaita colors) and ignore `ColorScheme`.

Brightness: `SettingsList.brightness` if set; otherwise `applicationType` picks `Theme` (`material`), `CupertinoTheme` (`cupertino`), or, for `both`, `CupertinoTheme` when the app runs on iOS/macOS and `Theme` elsewhere (by the detected platform, not the `platform` override).

Layout: `SettingsList` sizes its default padding from its own width (`LayoutBuilder`), keeping content in an 810 column (680 on web; 1000 with 36 margins on Windows; on Linux an `AdwClamp`-style column that eases from 400 to at most 600, in sp), centered or at the start edge (`crossAxisAlignment: start`). `contentPadding` replaces all of that. An empty `SettingsSection` renders `SizedBox.shrink()`.

### `DevicePlatform.device` is a sentinel

`DevicePlatform.device` means "auto-detect" and is valid only as input to `SettingsList`. It must never reach the switch statements in tiles, sections or `ThemeProvider` (they throw). `PlatformUtils.detectPlatform()` resolves it: `kIsWeb` → web, otherwise `Theme.of(context).platform`. Its `default:` branch sends platforms that only exist in Flutter forks (e.g. OpenHarmony) to the iOS style; keep it, or forks stop compiling.

### `IOSSettingsTileAdditionalInfo`

An internal `InheritedWidget` that `IOSSettingsSection` puts above each tile to say whether to round the top/bottom corners and draw the divider. A tile's `description` becomes a footer outside the card, so the next tile starts a new rounded card.

### Design specs (2026 look)

- **iOS** (iOS 26/27 Settings): 26pt continuous corners (`ClipRSuperellipse`), 20pt side margins, 52pt rows (16 + 17pt text + 16), 17pt tile text, 17pt semibold section headers in the secondary grey, value at most half the row on one line, chevron on navigation tiles, `CupertinoSettingsSwitch`. Headers are not upper-cased.
- **Android** (Android 16/17 Settings): each tile on its own card, 2dp apart, 20dp outer / 4dp inner corners, 16dp side margins, on a `surfaceContainer` page; 16sp titles, 14sp medium section titles in `primary`; Material `Switch` with check/cross thumb icons; no chevron.
- **Web** (Chrome settings): cards with 8px corners and elevation 2, 14px titles, 13px descriptions, 20px leading icons, chevron on navigation tiles, 680px max column (810 for iOS and Android, 1000 for Windows, at most 600 for GNOME), 16px side margins in narrow windows.
- **Windows** (Windows 11 Settings, WinUI 3 / CommunityToolkit `SettingsCard`): one card per tile, 4px corners, 1px border (`dividerColor`), 4px apart, 68px min height (52 compact), 16px padding inside the 1px border; 20px icons with 2/20 margins; Body 14/20 titles, Caption 12/16 descriptions; value in secondary text and a painted 13px chevron at the end; section headers 14/20 semibold with margin 1,30,0,6; below 476px card width the content moves under the header, below 286px the icon hides. Clickable cards (with `onPressed`) get the WinUI hover, pressed and 2px+1px focus-ring states; others don't react. 1000px column with 36px margins (16 below 641px), 36 at the bottom. Colors are WinUI theme resources in `lib/src/utils/fluent_tokens.dart`; inside a list the Fluent controls pick light or dark from the card color. Fonts come from the app (Segoe UI on Windows; Segoe UI Variable is not bundled).
- **GNOME** (GNOME Settings 51, libadwaita 1.10): one card per section (`.boxed-list`: 12px corners, 3-layer soft shadow painted only outside the card), 12px side margins, 24px between groups and above the first, 54px rows (2 + 50 + 2), full-width 1px separators, text 14px in, 16px leading icons 12px before the title, 14.67px titles, 12.22px subtitles at 55% opacity (`description` and `titleDescription` both become subtitles), bold 14.67px group titles in a 34px row 6px above the card, dimmed `value` at the end, painted `go-next-symbolic` arrow on navigation tiles, hover 3% / pressed 8% of the foreground, 2px accent focus ring, fixed libadwaita colors. Sources: the libadwaita 1.10 stylesheet (`src/stylesheet/_colors.scss`, `widgets/_lists.scss`, `_preferences.scss`, `_switch.scss`) and `src/adw-clamp-layout.c`.
- **`CupertinoSettingsSwitch`**: iOS 26 switch drawn with a `CustomPainter` (no platform view, shader or backdrop filter). 63x28 track, 37x24 thumb, Liquid Glass-style lens while pressed or dragged. The lens paints outside the 63x28 box, so don't clip it tightly.
- **`FluentSettingsSwitch`**: WinUI `ToggleSwitch` drawn with a `CustomPainter`: 40x20 track, knob 12 / 14 hovered / 17x14 pressed (anchored 3px in), accent `#005FB8`/`#60CDFF` at 90%/80% when hovered/pressed, black knob on the dark-mode accent. The keyboard focus ring paints outside its 40x20 box.
- **`AdwaitaSettingsSwitch`**: GtkSwitch drawn with a `CustomPainter`: 46x26 pill, round 20px knob inset 3px, `#3584E4` when on, foreground at 15% when off (lighter on hover, darker while pressed), grey knob when off in dark mode, 100ms ease-out-cubic, drag past the middle, Space/Enter, half opacity when disabled.

Tap behavior on switch tiles differs on purpose: Android, GNOME and web toggle on a row tap and never call `onPressed`; iOS and Windows toggle only on the switch and call `onPressed` for the rest of the row. GNOME rows take the keyboard focus themselves; the switch inside is excluded from focus.

### Public API surface (the only exports)

`lib/settings_ui.dart` re-exports exactly:

- `SettingsList` (+ `ApplicationType`)
- `SettingsSection`, `AbstractSettingsSection`, `CustomSettingsSection`
- `SettingsTile` (+ `SettingsTileType`), `AbstractSettingsTile`, `CustomSettingsTile`
- `CupertinoSettingsSwitch`, `FluentSettingsSwitch`, `AdwaitaSettingsSwitch`
- `DevicePlatform`, `PlatformUtils`
- `SettingsTheme`, `SettingsThemeData`

Everything else in `platforms/` is internal. Don't export it.

## Testing conventions

- `test/widget_test.dart` is the only entry point with a `main()`. Each file in `test/settings_tests/*_tests.dart` (and `test/utils_tests/`) defines a function such as `settingsTileTests(DevicePlatform platform)` or `nativeLookTests()`, and `widget_test.dart` calls it inside a `group`. A new test file does nothing until you call its function from `widget_test.dart`.
- Platform-parameterized helpers are called once per `DevicePlatform`. Tests pass the platform explicitly to `SettingsList` (via `TestWidgetScreen` in `test/test_widget_screen.dart` or `_wrapWithMaterialApp`) so they don't depend on the host.
- Wrap widgets in `MaterialApp`/`CupertinoApp` from material_ui/cupertino_ui. Find iOS-style switches with `find.byType(CupertinoSettingsSwitch)`, Windows ones with `find.byType(FluentSettingsSwitch)`, GNOME-style (Linux) ones with `find.byType(AdwaitaSettingsSwitch)`, others with `find.byType(Switch)`.
- `example/integration_test/integration_test.dart` drives the example app's gallery screens. It runs on a device, simulator or emulator (`-d`), not in CI.

## CI and release

- `.github/workflows/code-quality-tests.yml` runs on every push: `dart format --output=none --set-exit-if-changed .` → `flutter analyze .` → `flutter test --coverage --test-randomize-ordering-seed random` → `very_good_coverage` with **min_coverage: 60** (line coverage of `lib/`).
- `.github/workflows/conventional-pr-title.yml`: PR titles must follow Conventional Commits and stay within 100 characters.
- No automated publish. To release: bump `version` in `pubspec.yaml`, update `CHANGELOG.md`, `README.md` and `llms.txt`, tag, then `flutter pub publish`.
- `llms.txt` (repo root) is the reference that coding agents fetch from `master`, and the README's agent prompts link to it. Keep it in sync with the public API and platform behavior whenever either changes.
