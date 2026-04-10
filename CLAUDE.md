# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About this project

`settings_ui` is a published Flutter package (pub.dev: `settings_ui`, current version: `2.0.3`) that renders native-looking settings screens for Android, iOS, macOS, Windows, Linux, Fuchsia, and Web — all from a single API. It is used in production by thousands of apps.

## Commands

```bash
# Get dependencies
flutter pub get

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage --test-randomize-ordering-seed random

# Analyze for lint errors
flutter analyze .

# Fix formatting
flutter format .

# Check formatting without changing files (CI-style)
flutter format --set-exit-if-changed .

# Run the example app
cd example && flutter run
```

## Architecture

### Rendering strategy: platform dispatch

Every public widget (`SettingsList`, `SettingsSection`, `SettingsTile`) is a thin dispatcher. At build time each checks `SettingsTheme.of(context).platform` and returns one of three concrete platform implementations:

- `Android/Fuchsia/Linux` → Material widgets
- `iOS/macOS/Windows` → Cupertino widgets
- `Web` → Web-specific widgets (rounded cards, adjusted padding)

Platform implementations live alongside their dispatcher:

```
lib/src/tiles/
  settings_tile.dart          ← dispatcher
  platforms/
    android_settings_tile.dart
    ios_settings_tile.dart
    web_settings_tile.dart
```

Same pattern for `sections/` and `list/`.

### Theme propagation via `InheritedWidget`

`SettingsList` resolves platform and brightness, calls `ThemeProvider.getTheme()` to get hardcoded platform defaults, merges in any user-supplied `lightTheme`/`darkTheme` (`SettingsThemeData`), then pushes the result down the tree via `SettingsTheme` (an `InheritedWidget`).

All platform tile/section widgets read theme from `SettingsTheme.of(context).themeData`. Never pass theme as a constructor argument.

`ThemeProvider` (`lib/src/utils/theme_provider.dart`) contains all hardcoded color values for each platform/brightness combination. This is the main place to touch when fixing theme issues.

### `DevicePlatform.device` is a sentinel

`DevicePlatform.device` means "auto-detect at runtime" and is valid only as input to `SettingsList`. It must never reach the platform switch statements inside tiles/sections — doing so throws. `PlatformUtils.detectPlatform()` resolves it to a real platform.

### `IOSSettingsTileAdditionalInfo`

An extra `InheritedWidget` injected by `IOSSettingsSection` to tell each `IOSSettingsTile` whether to draw top/bottom border radius and whether to show the inter-tile divider. This is iOS/macOS/Windows only.

### Public API surface (the only exports)

`lib/settings_ui.dart` re-exports exactly:
- `SettingsList` (+ `ApplicationType` enum)
- `SettingsSection`, `AbstractSettingsSection`, `CustomSettingsSection`
- `SettingsTile` (+ `SettingsTileType` enum), `AbstractSettingsTile`, `CustomSettingsTile`
- `DevicePlatform`, `PlatformUtils`
- `SettingsTheme`, `SettingsThemeData`

Platform-specific implementations are internal and should not be part of the public API.

## Testing conventions

- Tests live in `test/` with a flat `widget_test.dart` entry point that calls helper functions grouped by concern (`settingsListTests`, `settingsSectionsTests`, `settingsTileTests`, etc.).
- Helper test functions are parameterised over `DevicePlatform` and called for every platform value.
- The `_wrapWithMaterialApp` / `TestWidgetScreen` helper wraps a tile or section in a `SettingsList` inside a `MaterialApp` and passes the desired platform explicitly so tests are platform-deterministic.
- CI requires ≥ 35% line coverage (`very_good_coverage`).

## CI / Release

- **CI** runs on every push: format check → `flutter analyze` → `flutter test --coverage` → coverage gate (35%).
- **PR titles** must follow Conventional Commits (enforced by `action-semantic-pull-request`).
- There is currently no automated publish workflow; a new version requires bumping `version` in `pubspec.yaml`, updating `CHANGELOG.md`, tagging, then running `flutter pub publish`.
